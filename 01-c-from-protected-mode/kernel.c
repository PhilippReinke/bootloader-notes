void _start() {
	char *character = (char*) 0xb8780;
	char *color = (char*) 0xb8781;

	int msg[] = {72, 101, 108, 108, 111, 32, 66, 97, 114, 101, 32, 77, 101, 116, 97, 108, 32, 58, 41};
	int msg_len = sizeof(msg) / sizeof(msg[0]);

	for (unsigned int i=0; i<msg_len; i++) {
		*character = msg[i];
		*color = 0x2f;

		// move pointers
		character += 2; color += 2;
	}
}

/*
text and background color

e.g. 0x00 = black text on black
     0x07 = lightgray text on black

0 black
1 blue
2 green
3 cyan
4 red
5 purple
6 brown
7 gray
8 dark gray
9 light blue
a light green
b light cyan
c light red
d light purple
e yellow
f white

https://animasci.com/play/edc431d0-c19b-472c-be61-a0378134cd74/Rick-Astley-Never-Gonna-Give-You-Up-Braille-MV
https://animasci.com/play/6143d4e3-64a0-43a3-8463-13d97192dc39/Hydrogen-Burning

*/
