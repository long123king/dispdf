printf "%d 0 obj\n" $1 > tflate_"$1".bin
printf "<</Length %d/Filter/FlateDecode>>stream\n" >> tflate_"$1".bin
cat deflated.bin | zlib-flate -compress >> tflate_"$1".bin
echo "" >> tflate_"$1".bin
echo "endstream" >> tflate_"$1".bin
echo "endobj" >> tflate_"$1".bin

target=$(ls -1 objects | grep "_obj_"$1".bin") 
rm objects/$target
mv tflate_"$1".bin objects/$target
