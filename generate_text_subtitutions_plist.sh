#!/bin/bash

###
### this thing will get your a valid text substitutions plist file created from csv.
###
### for example, a srouce file like this:
###
### sHoRt;Very Long Substitution
### OMG;Oh my god
###
### Will end up being:
###
### <?xml version="1.0" encoding="UTF-8"?>
### <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
### <plist version="1.0">
### <array>
###         <dict>
###                 <key>phrase</key>
###                 <string>Very Long Substitution</string>
###                 <key>shortcut</key>
###                 <string>sHoRt</string>
###         </dict>
###         <dict>
###                 <key>phrase</key>
###                 <string>Oh my god</string>
###                 <key>shortcut</key>
###                 <string>OMG</string>
###         </dict>
### </array>
### </plist>
###

### settings
delimeter=";"		# use ; as default delimeters for csv files
out="${1%.*}.plist"	# use original filename, with extension replaced to .plist as output by default
debug="off"		# set to on to get info out instead of writing to file

### functions
function err { echo -ne " ! Error: $1\n ! This is fatal, exiting.\n"; exit 1; }
function dbg { if [[ $debug == "on" ]]; then echo "$1"; return 0; else return 1; fi; }

function c_top {
   res='<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>'
}

function c_end {
   res='</array>
</plist>'
}

function c_build {
   res=""; notes=""
   prefivs=${IFS}
   IFS=$'\n'
   for line in `cat "$1"`; do 
       key=`echo $line | sed "s#$delimeter.*##"`; val=`echo $line | sed "s#.*$delimeter##"`
       c_check "$key" #|| notes="$notes\nkey $key has delimter $delimeter found, can be a problem\n"
       c_check "$val" #|| notes="$notes\nvalue $val has delimeter $delimeter found, can be a problem\n"
       c_filter "$key" || continue

       res="$res
         <dict>
                 <key>phrase</key>
                 <string>$val</string>
                 <key>shortcut</key>
                 <string>$key</string>
         </dict>"

   done
   IFS=$prefivs
   c_notes "$notes"
}

function c_check { 
   if [[ `echo "$1" |grep $delimeter` != "" ]]; then notes="${notes}\n     (i) key/value $1 has delimter $delimeter found, can be a problem..."; return 1; fi
}

function c_filter {
   if [[ `echo "$1" |grep "^#"` != "" ]]; then notes="${notes}\n     (i) skipping comment $1"; return 1; fi
   if [[ `echo "$1"` != `echo "$1" |sed 's# ##g'` ]]; then notes="${notes}\n     (i) $1 has space in that, Apple will filter this anyway, skipping..."; return 1;fi
}

function c_notes { if [[ "$1" == "" ]]; then notes="none, all good"; fi; }
function put_out { echo "$1" > $out || err "Failed writing content to $out"; }  

### pre-start evaulations
if [[ "$1" == "" ]]; then err "Woa I need a file to work with."; fi
if [ ! -f "$1" ]; then err "Woa that file doesn't exist"; else in="$1"; fi
if [[ "$2" != "" ]] && [[ `echo -ne "$2" | wc -c |sed 's# ##g'` == "1" ]]; then delimeter="$2"; fi # else echo "2nd param: '$2' length '`echo $2 | wc -c |sed 's# ##g`'";fi
if [[ "$2" != "" ]] && (( `echo -ne "$2" | wc -c |sed 's# ##g'` > 1 )) && [[ "${2}" != "debug" ]]; then out=${out%.*}.$2; echo $out; fi
if [[ "$3" != "" ]] && (( `echo -ne "$3" | wc -c |sed 's# ##g'` <= 5 )) && [[ "${3}" != "debug" ]]; then out=${out%.*}.$3; echo $out; fi

dbg_chk=`echo $1 $2 $3 $4 | tr A-Z a-z`
if [[ `echo "$dbg_chk" |grep -i " debug"` != "" ]]; then debug=on; fi

### kick it
echo -ne " [+] Yo `basename $0`\n     Input: $1\n     Output: $out\n     Delimeter set: $delimeter\n\n [+] Kicking it..."

c_top && out_top="$res"		|| err "Building plist heading has failed"
c_build "$in" && out_mid="$res"	|| err "Constructing lines based on file is failing"
c_end && out_end="$res"		|| err "Building plist end piece has failed"

confirm=" [+] Completed: $out is out"
dbg "$out_top $out_mid $out_end" && confirm=" [+] Debug more, no writing to $out" || put_out "$out_top $out_mid $out_end"

echo -ne "\n$confirm\n [-] Notes: $notes\n\n \o/ kthxbye.\n\n"

### kthxbye
exit 0

