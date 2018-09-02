# genTextSubst

Text subtitutions generator for MacOS.

This thing will get your a valid text substitutions plist file created from csv.
for example, a srouce file like this:

```
sHoRt;Very Long Substitution
OMG;Oh my god
```

Will end up being:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
         <dict>
                 <key>phrase</key>
                 <string>Very Long Substitution</string>
                 <key>shortcut</key>
                 <string>sHoRt</string>
         </dict>
         <dict>
                 <key>phrase</key>
                 <string>Oh my god</string>
                 <key>shortcut</key>
                 <string>OMG</string>
         </dict>
 </array>
 </plist>
```

## Quick Start
1. Create a csv where each line is constructed with: shortprase;longphrase
2. Run generate_text_subtitutions_plist.sh <filename>.csv to generate <filename>.plist
3. Navigate to MacOS/Settings/Keyboard/Text, and simply drag & drop the generated file into your text substitutions list area.
4. Magic.

## Options

Options:
    delimteter - add a single character delimeter as 
    debug - add debug as a parameter, and this will print instead of write
    delimeter - add
    
## Examples

./generate_text_subtitutions_plist <filename>.csv debug
- will not write, just show.

./generate_text_subtitutions_plist <filename>.csv xml
- output xml file instead of .plist

./generate_text_subtitutions_plist <filename>.csv ","
- use comma as delimtetr instead of ;. Should work with most common delimeter types, but please note that # can be tricky.

./generate_text_subtitutions_plist <filename>.csv ":" txt
- use colon as delimeter and output to a .txt file (will still be XML)

./generate_text_subtitutions_plist <filename>.csv "/" dat debug
- use / as delimeter, would output to a .dat file, if debug weren't added (no write, just print out).


There's a few validation options where keys / values with multiple delimeters will be higlighted as warnings, but no XML validation is happening, .e.g characters that can break XML will break this one too. Caution with < > and alike please.




