ENT.Base			= 'duck_instrument_base'
ENT.Type			= 'anim'
ENT.PrintName		= '#duckInstrument.Piano'
ENT.Category		= '#duckInstrument.Category'
ENT.Author			= 'DeadDuck'
ENT.Spawnable		= true
ENT.AdminSpawnable 	= true

local darker = Color( 100, 100, 100, 150 )

ENT.Keys = {
	[KEY_1] =
	{
		Sound = 'C2', Material = 'left', Label = '1', X = 19, Y = 86,
		Shift = { Sound = 'C#2', Material = 'top', Label = '!', X = 33, Y = 31, TextX = 7, TextY = 90, Color = darker },
	},
	[KEY_2] =
	{
		Sound = 'D2', Material = 'middle', Label = '2', X = 44, Y = 86,
		Shift = { Sound = 'D#2', Material = 'top', Label = '@', X = 64, Y = 31, TextX = 7, TextY = 90, Color = darker },
	},
	[KEY_3] = { Sound = 'E2', Material = 'right', Label = '3', X = 69, Y = 86 },
	[KEY_4] =
	{
		Sound = 'F2', Material = 'left', Label = '4', X = 94, Y = 86,
		Shift = { Sound = 'F#2', Material = 'top', Label = '$', X = 108, Y = 31, TextX = 7, TextY = 90, Color = darker },
	},
	[KEY_5] =
	{
		Sound = 'G2', Material = 'leftmid', Label = '5', X = 119, Y = 86,
		Shift = { Sound = 'G#2', Material = 'top', Label = '%', X = 136, Y = 31, TextX = 7, TextY = 90, Color = darker },
	},
	[KEY_6] =
	{
		Sound = 'A2', Material = 'rightmid', Label = '6', X = 144, Y = 86,
		Shift = { Sound = 'A#2', Material = 'top', Label = '^', X = 164, Y = 31, TextX = 7, TextY = 90, Color = darker },
	},
	[KEY_7] = { Sound = 'B2', Material = 'right', Label = '7', X = 169, Y = 86 },
	[KEY_8] =
	{
		Sound = 'C3', Material = 'left', Label = '8', X = 194, Y = 86,
		Shift = { Sound = 'C#3', Material = 'top', Label = '*', X = 208, Y = 31, TextX = 7, TextY = 90, Color = darker },
	},
	[KEY_9] =
	{
		Sound = 'D3', Material = 'middle', Label = '9', X = 219, Y = 86,
		Shift = { Sound = 'D#3', Material = 'top', Label = '(', X = 239, Y = 31, TextX = 7, TextY = 90, Color = darker },
	},
	[KEY_0] = { Sound = 'E3', Material = 'right', Label = '0', X = 244, Y = 86 },
	[KEY_Q] =
	{
		Sound = 'F3', Material = 'left', Label = 'q', X = 269, Y = 86,
		Shift = { Sound = 'F#3', Material = 'top', Label = 'Q', X = 283, Y = 31, TextX = 7, TextY = 90, Color = darker },
	},
	[KEY_W] =
	{
		Sound = 'G3', Material = 'leftmid', Label = 'w', X = 294, Y = 86,
		Shift = { Sound = 'G#3', Material = 'top', Label = 'W', X = 310, Y = 31, TextX = 7, TextY = 90, Color = darker },
	}, -- 310
	[KEY_E] =
	{
		Sound = 'A3', Material = 'rightmid', Label = 'e', X = 319, Y = 86,
		Shift = { Sound = 'A#3', Material = 'top', Label = 'E', X = 339, Y = 31, TextX = 7, TextY = 90, Color = darker },
	}, -- 339
	[KEY_R] = { Sound = 'B3', Material = 'right', Label = 'r', X = 344, Y = 86 },
	[KEY_T] =
	{
		Sound = 'C4', Material = 'left', Label = 't', X = 369, Y = 86,
		Shift = { Sound = 'C#4', Material = 'top', Label = 'T', X = 383, Y = 31, TextX = 7, TextY = 90, Color = darker },
	}, -- 383
	[KEY_Y] =
	{
		Sound = 'D4', Material = 'middle', Label = 'y', X = 394, Y = 86,
		Shift = { Sound = 'D#4', Material = 'top', Label = 'Y', X = 414, Y = 31, TextX = 7, TextY = 90, Color = darker },
	}, -- 415
	[KEY_U] = { Sound = 'E4', Material = 'right', Label = 'u', X = 419, Y = 86 },
	[KEY_I] =
	{
		Sound = 'F4', Material = 'left', Label = 'i', X = 444, Y = 86,
		Shift = { Sound = 'F#4', Material = 'top', Label = 'I', X = 458, Y = 31, TextX = 7, TextY = 90, Color = darker },
	}, -- 459
	[KEY_O] =
	{
		Sound = 'G4', Material = 'leftmid', Label = 'o', X = 469, Y = 86,
		Shift = { Sound = 'G#4', Material = 'top', Label = 'O', X = 486, Y = 31, TextX = 7, TextY = 90, Color = darker },
	}, -- 486
	[KEY_P] =
	{
		Sound = 'A4', Material = 'rightmid', Label = 'p', X = 494, Y = 86,
		Shift = { Sound = 'A#4', Material = 'top', Label = 'P', X = 514, Y = 31, TextX = 7, TextY = 90, Color = darker },
	}, -- 515
	[KEY_A] = { Sound = 'B4', Material = 'right', Label = 'a', X = 519, Y = 86 },
	[KEY_S] =
	{
		Sound = 'C5', Material = 'left', Label = 's', X = 544, Y = 86,
		Shift = { Sound = 'C#5', Material = 'top', Label = 'S', X = 558, Y = 31, TextX = 7, TextY = 90, Color = darker },
	}, -- 559
	[KEY_D] =
	{
		Sound = 'D5', Material = 'middle', Label = 'd', X = 569, Y = 86,
		Shift = { Sound = 'D#5', Material = 'top', Label = 'D', X = 590, Y = 31, TextX = 7, TextY = 90, Color = darker },
	}, -- 590
	[KEY_F] = { Sound = 'E5', Material = 'right', Label = 'f', X = 594, Y = 86 },
	[KEY_G] =
	{
		Sound = 'F5', Material = 'left', Label = 'g', X = 619, Y = 86,
		Shift = { Sound = 'F#5', Material = 'top', Label = 'G', X = 633, Y = 31, TextX = 7, TextY = 90, Color = darker },
	}, -- 633
	[KEY_H] =
	{
		Sound = 'G5', Material = 'leftmid', Label = 'h', X = 644, Y = 86,
		Shift = { Sound = 'G#5', Material = 'top', Label = 'H', X = 661, Y = 31, TextX = 7, TextY = 90, Color = darker },
	}, -- 661
	[KEY_J] =
	{
		Sound = 'A5', Material = 'rightmid', Label = 'j', X = 669, Y = 86,
		Shift = { Sound = 'A#5', Material = 'top', Label = 'J', X = 690, Y = 31, TextX = 7, TextY = 90, Color = darker },
	}, -- 690
	[KEY_K] = { Sound = 'B5', Material = 'right', Label = 'k', X = 694, Y = 86 },
	[KEY_L] =
	{
		Sound = 'C6', Material = 'left', Label = 'l', X = 719, Y = 86,
		Shift = { Sound = 'C#6', Material = 'top', Label = 'L', X = 734, Y = 31, TextX = 7, TextY = 90, Color = darker },
	}, -- 734
	[KEY_Z] =
	{
		Sound = 'D6', Material = 'middle', Label = 'z', X = 744, Y = 86,
		Shift = { Sound = 'D#6', Material = 'top', Label = 'Z', X = 765, Y = 31, TextX = 7, TextY = 90, Color = darker },
	}, -- 765
	[KEY_X] = { Sound = 'E6', Material = 'right', Label = 'x', X = 769, Y = 86 },
	[KEY_C] =
	{
		Sound = 'F6', Material = 'left', Label = 'c', X = 794, Y = 86,
		Shift = { Sound = 'F#6', Material = 'top', Label = 'C', X = 809, Y = 31, TextX = 7, TextY = 90, Color = darker },
	}, -- 809
	[KEY_V] =
	{
		Sound = 'G6', Material = 'leftmid', Label = 'v', X = 819, Y = 86,
		Shift = { Sound = 'G#6', Material = 'top', Label = 'V', X = 837, Y = 31, TextX = 7, TextY = 90, Color = darker },
	}, -- 837
	[KEY_B] =
	{
		Sound = 'A6', Material = 'rightmid', Label = 'b', X = 844, Y = 86,
		Shift = { Sound = 'A#6', Material = 'top', Label = 'B', X = 865, Y = 31, TextX = 7, TextY = 90, Color = darker },
	}, -- 865
	[KEY_N] = { Sound = 'B6', Material = 'right', Label = 'n', X = 869, Y = 86 },
	[KEY_M] = { Sound = 'C7', Material = 'full', Label = 'm', X = 894, Y = 86 },
}