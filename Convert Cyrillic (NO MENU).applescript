(*
Script:
	Convert Cyrillics for your music files the following fields only: "Name", "Artist", "Album Artist"
Version:
	0.5 - "no menu version"
CahngeLog:
	
	Merged initial dialogue changes from Teodor Zlatanov -- you can now choose what details require conversion.
Author:
	Ruslan Schelkunov (ruslanss@gmail.com) (Contributor)
	Andrei Popov (ceesaxp@gmail.com)

The issue:
	ID3 tags that are embedded in MP3 files generated on Windows or (shudder) DOS machines use extended ASCII to store Cyrillics.  When you import such files into iTunes, it assumes that they're all in MacRoman coding page** and happily garbles them up.

The search to solve it:
	One way to do that is to convert tags *before* importing them into iTunes.  This might work, but I have not tried it, don't know.
	Another way was to try and fix them once they're in using a `do shell command' call from AppleScript.  No luck there, although iconv -f cp866 -t utf8 *almost* does the right thing.  Almost, but not quite.

Solution:
	I had to manually recode conversion table, based on MacRoman ASCII page (http://www.iro.umontreal.ca/~felipe/IFT1010-Hiver2005/Complements/ascii.html) viewed as if it were Cyrillic (Mac) page in Camino, then assigning proper UNICODE values to each code point.

Credits:
	Thanks to StefanK at MacScripter BBS  for helping me sort out a few AppleScript issues.
	Thanks to Sergii Denega for providing a number of further fixes, most importantly to make script work on both PPC and Intel and fixing the issue with multiple tracks to be convereted.
	Thanks to Teodor Zlatanov for providing changes that allow choosing what fields/tags should be converted.

----
** Some say this would not be the case if International pannel lists Russian as first language -- I have not tested that

*)

property charCodeMap : {�
	"0020", "0020", "0020", "0020", "0020", "0020", "0020", "0020", "0020", "0009", "000A", "0020", "0020", "000D", "0020", "0020", �
	"0020", "0020", "0020", "0020", "0020", "0020", "0020", "0020", "0020", "0020", "0020", "0020", "0020", "0020", "0020", "0020", �
	"0020", "0021", "0022", "0023", "0024", "0025", "0026", "0027", "0028", "0029", "002A", "002B", "002C", "002D", "002E", "002F", �
	"0030", "0031", "0032", "0033", "0034", "0035", "0036", "0037", "0038", "0039", "003A", "003B", "003C", "003D", "003F", "003F", �
	"0040", "0041", "0042", "0043", "0044", "0045", "0046", "0047", "0048", "0049", "004A", "004B", "004C", "004D", "004E", "004F", �
	"0050", "0051", "0052", "0053", "0054", "0055", "0056", "0057", "0058", "0059", "005A", "005B", "005C", "005D", "005E", "005F", �
	"0060", "0061", "0062", "0063", "0064", "0065", "0066", "0067", "0068", "0069", "006A", "006B", "006C", "006D", "006E", "006F", �
	"0070", "0071", "0072", "0073", "0074", "0075", "0076", "0077", "0078", "0079", "007A", "007B", "007C", "007D", "007E", "007F", �
	"0414", "0415", "0417", "0419", "0421", "0426", "042C", "0431", "0430", "0432", "0434", "0433", "0435", "0437", "0439", "0438", �
	"043A", "043B", "043D", "043C", "043E", "043F", "0441", "0443", "0442", "0444", "0446", "0445", "044A", "0449", "044B", "044C", �
	"042D", "00A1", "00A2", "00A3", "00A4", "00A5", "00A6", "042F", "00A8", "00A9", "0411", "0491", "0401", "00AD", "0416", "0428", �
	"00B0", "00B1", "00B2", "00B3", "0490", "00B5", "00B6", "00B7", "00B8", "00B9", "00BA", "0404", "0454", "00BD", "0436", "0448", �
	"0457", "00C1", "00C2", "00C3", "00C4", "00C5", "00C6", "00C7", "00C8", "00C9", "00CA", "0410", "0413", "0425", "00CE", "00CF", �
	"00D0", "00D1", "0456", "0406", "00D4", "00D5", "0447", "0427", "044F", "00D9", "00DA", "00DB", "0420", "0440", "042E", "044E", �
	"044D", "00E1", "00E2", "00E3", "00E4", "0412", "041A", "0411", "041B", "0419", "041D", "041E", "041F", "041C", "0423", "0424", �
	"00F0", "0422", "042A", "042B", "0429", "00F5", "00F6", "00F7", "0407", "00F9", "00FA", "00FB", "0451", "00FD", "00FE", "00FF"}

tell application "iTunes"
	
	with timeout of 30000 seconds
		repeat with _track in selection
			tell _track
				try
					set name to my fixCyrillics(get name)
					set artist to my fixCyrillics(get artist)
					set album artist to my fixCyrillics(get album artist)
					set album to my fixCyrillics(get album)
				end try
			end tell
		end repeat
	end timeout
end tell

on fixCyrillics(str)
	set outStr to "" as Unicode text
	repeat with i in characters of str
		set charCode to ASCII number of i
		set Uni to item (charCode + 1) of charCodeMap
		set Uni to text 3 thru 4 of Uni & text 1 thru 2 of Uni
		set outStr to outStr & (run script "�data utxt" & Uni & "�" as Unicode text)
	end repeat
	return outStr
end fixCyrillics