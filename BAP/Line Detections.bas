'Program name: basumo01.bas for Basic Atom Pro.
'This version uses the pulsout function to control the motors.
'This is for a sumo with two line detectors, but no opponent detectors.

left_motor var word
right_motor var word
backup var byte
turn var byte
edge_detect var byte
aa var byte

input p2
input p3
low 14		'Left motor-control channel
low 15		'Right motor-control channel
backup = 20	'this affects how far the robot backs up from the line.
turn = 20	'this affects how far the robot turns after backing.

sound 9, [100\880, 100\988, 100\1046, 100\1175]	'three quick ascending beeps.

for aa=1 to 5	'Beep at the end of each of the 5 seconds in the delay.
pause 900
sound 9, [100\880]
next

start:						'Go forward at max speed.
left_motor = 2000
right_motor = 4000
gosub servo_pulses

edge_detect = (ina&%1100)	'Look at the 1st I/O nibble and mask off bit 1 and 2.
if edge_detect = %0100 then left_detect		'Look for left edge detector.
if edge_detect = %1000 then right_detect	'Look for right edge detector.
if edge_detect = %1100 then left_detect		'Look for both left and right. 
goto start

left_detect:				'This is where the pulses are setup for the 
for aa=1 to backup			'Scorpion motor controller for left detect.
left_motor = 4000
right_motor = 2000
gosub servo_pulses
next
for aa=1 to turn
left_motor = 4000
right_motor = 4000
gosub servo_pulses
next
goto start

right_detect:				'This is where the pulses are setup for the 
for aa=1 to backup			'Scorpion motor controller for right detect.
left_motor = 4000
right_motor = 2000
gosub servo_pulses
next
for aa=1 to turn
left_motor = 2000
right_motor = 2000
gosub servo_pulses
next
goto start

servo_pulses:				'This is where the pulses are actually generated.
pulsout 14, left_motor 		'2000 = forward, 4000 = reverse, 3000 = stop
pulsout 15, right_motor 	'4000 = forward, 2000 = reverse, 3000 = stop
pause 20
return