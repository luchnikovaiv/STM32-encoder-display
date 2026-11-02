.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

#include "stm32f10x.s"

	.section .text.main
	.global main
	.type main, %function
main:
	ldr		r0, =PERIPH_BB_BASE+(RCC_APB2ENR-PERIPH_BASE)*32 + 2*4 @ вычисляем адрес для BitBanding 2-го бита
	mov		r1, #1 @ включаем тактирование порта A (во 2-й бит RCC_APB2ENR пишем '1`)
	str 	r1, [r0] @ загружаем это значение

	ldr	r0, =GPIOA_CRL @ адрес PA0-PA7
	ldr	r1, =0x33334444 @ настройка PA4-PA7 на выход (3)
	str	r1, [r0] @ сохранить настройку

	ldr		r0, =GPIOA_CRH @ адрес порта PA8-PA15
	ldr 	r1, =0x44444333 @ настройка PA8-PA10 на выход (3)
	str		r1, [r0] @ сохранить настройку

	movs	r4, #0 @ регистр значения индикатора, начало с 0

	ldr	r0, =GPIOA_IDR @ входные данные порта A
	ldr 	r1, [r0] @ читаем данные 16 входов
	ands	r5, r1, #2 @ оставляем только PA1-CLK (10/00)
	lsrs	r5, #1 @ сдвигаем до 1/0

loop:
	adr		r3, hex_table @ получаем адрес метки с таблицей
	ldrb	r3, [r3, r4] @ код из таблицы для текущей цифры
	lsls	r3, #4 @ сдвигаем на 4 бита, так как сегменты начинаются с PA4 (A-PA4)

	ldr	r1, =0x07F00000
	orr		r1, r3
	ldr		r0, =GPIOA_BSRR
	str	r1, [r0]

	ldr	r0, =GPIOA_IDR @ входные данные порта A
	ldr	r1, [r0] @ читаем данные 16 входов
	ands	r2, r1, #2 @ оставляем только PA1-CLK (10/00)
	lsrs	r2, #1 @сдвигаем до 1/0

	cmp	r2, r5 @ проверка изменения PA1-CLK
	beq	loop @ если неизменился, то не крутили, в начало цикла

	ands	r3, r1, #1 @CLK изменился, берем PA0-DT из входных данных полученных ранее

	eors	r3, r5, r3 @ xor CLK и DT
	cmp	r3, #1 @ проверка 1 или 0
	beq		inc_counter @ если 1, то увеличиваем
	b	dec_counter @ если 0, то уменьшаем

inc_counter:
	cmp	r4, #15 @ проверка что уже F (15)
	bge	update_state @ если да, то больше не увеличиваем и запоминаем состояние
	adds	r4, #1 @ если нет, то увеличиваем на 1
	b		update_state @ запоминаем состояние

dec_counter:
	cmp	r4, #0 @ проверка что уже 0
	ble		update_state @ если да, то запоминаем состояние
	subs	r4, #1 @ если нет, то уменьшаем и запоминаем состояние

update_state:
	bl	delay @ пауза от прокрутов
	ldr	r0, =GPIOA_IDR @ @ входные данные порта A
	ldr	r1, [r0] @ читаем данные всех 16 портов
	ands	r5, r1, #2 @ оставляем только PA1-CLK (10/00)
	lsrs	r5, #1 @ сдвигаем до 1/0
	b		loop @ цикл заново

hex_table: @ биты - сегменты, кроме первого
	.byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F @ 0,1,2,3,4,5,6,7,8,9
	.byte 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71 @ A, B, C, D, E, F
	.align 2
	.size main, .-main

	.section .text.delay
	.global delay
	.type delay, %function
delay:
	push	{r0} @ сохраняем r0 в стек
	ldr	r0, =0x2FFFF @ количество повторений цикла задержки
delay_loop:
	subs	r0, #1 @ уменьшает счетчик цикла на 1
	bne	delay_loop @ если не 0, повторяем цикл
	pop		{r0} @ возвращаем r0
	bx		lr @ возврат туда, откуда вызвали
	.size delay, .-delay
