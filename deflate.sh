target=$(ls -1 objects | grep "_obj_"$1".bin")
grep -Ubo --binary-file=text stream objects/$target | sed -e 's/:/ /g' | awk 'NR==1{printf("%d ",$1+7);}NR==2{printf("%d ", $1-10);}' > tdeflate_stream.bin
read xstart xend < tdeflate_stream.bin
dd if=objects/$target of=flated.bin bs=1 skip=$xstart count=$[ $xend - $xstart ]
cat flated.bin | zlib-flate -uncompress > deflated.bin
