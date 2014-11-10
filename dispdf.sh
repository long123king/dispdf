header_start=0
header_len=15

tag=$(echo $1 | awk 'BEGIN{FS="."}{print $1}')
echo $tag

xref_start=$(strings -a -t d $1 | grep -e "\bxref\b" | awk '{print $1}')
trailer_start=$(strings -a -t d $1 | grep -e "\btrailer\b" | awk '{print $1}')
#echo $xref_start
#echo $trailer_start

xref_len=$(echo "$trailer_start - $xref_start" | bc)
#echo $xref_len

header_dump=$(echo "$1" | sed -re 's/^(.*)\.pdf/tdis\_\1\_header\.bin/g')
dd if=$1 of=$header_dump bs=1 skip=$header_start count=$header_len

xref_dump=$(echo "$1" | sed -re 's/^(.*)\.pdf/tdis\_\1\_xref\.bin/g')
dd if=$1 of=$xref_dump bs=1 skip=$xref_start count=$xref_len

trailer_dump=$(echo "$1" | sed -re 's/^(.*)\.pdf/tdis\_\1\_trailer\.bin/g')
dd if=$1 of=$trailer_dump bs=1 skip=$trailer_start

#cat tdis_daniel_xref.bin | awk 'NF==3' | awk 'NR!=1{printf("%d 0 obj is at offset: %d\n", NR-1, $1);}'
cat tdis_"$tag"_xref.bin | awk 'NF==3' | awk 'NR!=1{printf("%d %d\n", $1, NR-1);}' | sort > tdis_"$xref_dump"
echo "$xref_start 0" >> tdis_"$xref_dump"
cat tdis_tdis_"$tag"_xref.bin | awk 'BEGIN{loffset=0;lobjnum=0;}{printf("%3d %3d %3d\n", loffset, $1-loffset, lobjnum);loffset=$1;lobjnum=$2;}' | awk 'NR!=1' > tdis_metrics_"$xref_dump"

if [ ! -d objects ]
then
    mkdir objects
fi
cat tdis_metrics_"$xref_dump" | while read offset len objn
do
#echo $offset, $len, $objn
obj_name=$(echo "$1_$objn" | sed -re 's/^(.*)\.pdf/tdis\_\1\_obj/g' | awk '{printf("objects/%s.bin", $0);}')
#echo $obj_name
dd if=$1 of=$obj_name bs=1 skip=$offset count=$len
done

#grep -Ubo --binary-file=text stream tdis_daniel_obj_2.bin | sed -e 's/:/ /g' | awk 'NR==1{printf("%d ",$1+7);}NR==2{printf("%d ", $1-10);}' > tdis_stream.bin
#read xstart xend < tdis_stream.bin
#dd if=tdis_daniel_obj_2.bin of=flated.bin bs=1 skip=$xstart count=$[ $xend - $xstart ]
#cat flated.bin | zlib-flate -uncompress > deflated.bin
