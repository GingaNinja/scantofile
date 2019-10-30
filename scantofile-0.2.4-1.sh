#! /bin/sh
set +o noclobber
#
#   $1 = scanner device
#   $2 = friendly name
#

#   
#       100,200,300,400,600
#
resolution=300
device="$1"
BASE=~/brscan
mkdir -p $BASE
if [ "`which usleep  2>/dev/null `" != '' ];then
    usleep 100000
else
    sleep  0.1
fi
output_tmp=$BASE/$(date | sed s/' '/'_'/g | sed s/'\:'/'_'/g)
echo "scan from $2($device)"
scanadf --resolution $resolution -o"$output_tmp"_%04d 
#--device-name 'brother4:net1;dev0'

for pnmfile in $(ls $output_tmp*); do
	echo pnmcrop -left -right -top -bottom -sides "$pnmfile" > "$pnmfile".crop
	pnmcrop -left -right -top -bottom -sides "$pnmfile" > "$pnmfile".crop
	echo pnmtops "$pnmfile".crop "$pnmfile".ps
	pnmtops -equalpixels -dpi=$resolution "$pnmfile".crop > "$pnmfile".ps
       #	-imagewidth 8.27 -imageheight 11.69 -width 8.27 -height 11.69 "$pnmfile".crop >"$pnmfile".ps
	rm -f "$pnmfile"
	rm -f "$pnmfile".crop
done

echo /usr/bin/gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="$output_tmp".pdf -f $(ls "$output_tmp"*.ps)
/usr/bin/gs -q -dNOPAUSE -sPAPERSIZE=a4 -dBATCH -sDEVICE=pdfwrite -sOutputFile="$output_tmp".pdf -f $(ls "$output_tmp"*.ps)
for psfile in $(ls "$output_tmp"*.ps)
do
	rm $psfile
done
echo  $output_tmp is created.
