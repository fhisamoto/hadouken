#
# This script is a test for running the bfast in a pipe
# the IO must be async because the emition of the alignment will be delayed 
# because of the bfast internal temp file.
#


require 'open3'

#fake emit
def emit(x)
  puts x
end

s1 = %Q\
@SRR033650.56 solid0045_20080529_1_C_elegans_1_21_111 length=25
T1230020300000133100121222
+SRR033650.56 solid0045_20080529_1_C_elegans_1_21_111 length=25
!&/&-6&%(&$#&%$'+$'2$#&($,
\;

s2 = %Q\
@SRR033650.57 solid0045_20080529_1_C_elegans_1_21_121 length=25
T3033123312113323202133031
+SRR033650.57 solid0045_20080529_1_C_elegans_1_21_121 length=25
!#712&%=233',;>-31(&(&3%,)
\;

cmd=%Q\
bfast  match -A 1 -f c_elegans.WS210.dna.fa  -T /scratch/   | bfast localalign  -A 1 -f c_elegans.WS210.dna.fa  | bfast postprocess -U -A 1 -a 4  -o 1  -f c_elegans.WS210.dna.fa
\;

cmd2=%Q\
bfast  match -A 1 -f c_elegans.WS210.dna.fa  -T /scratch/ | bfast localalign  -A 1 -f c_elegans.WS210.dna.fa | bfast postprocess -U -A 1 -a 4  -o 1  -f c_elegans.WS210.dna.fa
\;

cmd3=%Q\
bfast easyalign -A 1 -T /scratch/ -f c_elegans.WS210.dna.fa
\

Open3.popen3(cmd2) do |stdin, stdout, stderr| 
  t1 = Thread.new do
    stdin.puts s1
    stdin.puts s2
    stdin.close
  end
  t2 = Thread.new do
    while(!stdout.eof?) 
      IO.select([stdout])
      emit stdout.readline
    end
  end
  t1.join
  t2.join
end

