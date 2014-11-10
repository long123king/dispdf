target=$1
dd if=$(ls -1 | grep "header.bin") of=$target bs=1 count=15

obj_offset=15
obj_nums=0
if [ -f "tas_generated_"$1"_xref.bin" ]
then
    rm "tas_generated_"$1"_xref.bin"
fi
for file in $(ls -1 objects)
do
    #echo $file
    obj_len=$(wc objects/$file | awk '{print $3}')
    dd if=objects/$file of=$target bs=1 count=$obj_len seek=$obj_offset
    printf "%010d %05d n\n" $obj_offset 0 >> "tas_generated_"$1"_xref.bin" 
    obj_offset=$[ $obj_offset + $obj_len ]
    obj_nums=$[ $obj_nums + 1 ]
done
echo "xref" >> $target
printf "0 %d\n" $obj_nums >> $target
echo "0000000000 65535 f" >> $target
cat "tas_generated_"$1"_xref.bin" >> $target

awk 'NR<=2' $(ls -1 | grep "trailer.bin") >> $target
echo "startxref" >> $target
echo $obj_offset >> $target
echo "%%EOF" >> $target

