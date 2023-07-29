### Lazy Dog

```
000125 " noq hvqcyuliwenkoocgjjbhzdbkegxtopnukrvbyasmyqdks"
000343 "r rawfdrfmjkzwarduuossipzzioeqhxihezwwqmvewiffvdzi"
000729 "tcqoorqcwwwdmstufymelutnkvyovga mwopl zjfflahrmiey"
001000 "tcqoorqcwwwdmstufymelutngkaovga mwopl zjfflaheovqr"
001331 "tcqoorqcwwwdmstufacljcxzgkaovga mwopl zjfflatwpddv"
001728 "tcqoorqcwwwdmstufymelutnkvyovga mww wzzscdnitwpddv"
002197 "tcqoorqcwwwdmstufymelutnkvyovga mww l zjgf i epdzi"
002744 "tcqoouqcwwwdmstufacljcxzgkaovga mww l zjffnitwpddv"
003375 "tcqoouqcwwwdmwtufymelutnkvyovga mww l zjfflitwpddv"
004096 "tcqoouqcwwwdmstufacljutnkvyovga mww l zscdnitwpddg"
004913 "tcqoouqcwwwdmwtufacljutnkvyovga mww l zjfflitwpddg"
005832 "tcqoouqcwwwdmstufyxelutnedyovga mww l zscdnitwpddg"
006859 "tcqoouqcwwwdmstufyxelutnedyovga mww l zycdnitwpddg"
008000 "tcqoouqcwwwdmwnufoxelutneuyovga mww l zscdnitwpddg"
009261 "tcqoouqcwwwdmwtufoxelutnedyovga mww l zycdnitwpddg"
010648 "tcqoouqcwwwdmwnufyxejutnedyovga mww l zycdnitwpddg"
012167 "tcqoouqcwwwdmwnufoxejutnedyovga mww l zycdnitwpddg"
013824 "tcqoouqcwwwdmwn foxejutnedyovga mww l zycdnitwpddg"
015625 "tcqoouqcwwwdmwn foxejutneddovga mww l zycwnitwpddg"
017576 "tcqoouqcwwwdmwn foxejutneddovga mww l zycwnitw ddg"
019683 "thqoouqcwwwdmwn foxejutneddovga mww l zycwnitw ddg"
021952 "thqoouqcwwwrmwn foxejutnedyovga mww l zycwnitw ddg"
024389 "thqoquqcwwwrmwn foxejutnedyovga mww l zycwnitw ddg"
027000 "thqoquqcwwwrmwn foxejutnedyovga tww l zycwnitw ddg"
029791 "thqoquqcwwarmwn fox jutneddovga tww l zycwnitw ddg"
032768 "thqoquqcwwwrmwn fox jumneddovga tww l zycwnitw ddg"
035937 "thqoquicwwwrmwn fox jumneddovga tww l zycwnitw ddg"
039304 "thqoquicwwwrown fox jumneddovga tww l zycwnitw ddg"
042875 "thqoquicwwwrown fox jumneddovga tww l zycwnitw dog"
046656 "thqoquicwwbrown fox jumneddovga tww l zycwnitw dog"
050653 "thqoquicwwbrown fox jumneddovga tww l zy wnitw dog"
054872 "thqoquicwwbrown fox jumned ovga tww l zy wnitw dog"
059319 "thq quicwwbrown fox jumned ovga tww l zy wnitw dog"
064000 "thq quicwwbrown fox jumned ovea tww l zy wnitw dog"
068921 "thq quicwwbrown fox jumped ovea tww l zy wnitw dog"
074088 "thq quicwwbrown fox jumped over tww l zy wnitw dog"
079507 "thq quicwwbrown fox jumped over tww l zy wnite dog"
085184 "thq quicwwbrown fox jumped over tww lazy wnite dog"
091125 "thq quicwwbrown fox jumped over twe lazy wnite dog"
097336 "the quicwwbrown fox jumped over twe lazy wnite dog"
103823 "the quici brown fox jumped over twe lazy wnite dog"
110592 "the quick brown fox jumped over twe lazy wnite dog"
117649 "the quick brown fox jumped over the lazy wnite dog"
125000 "the quick brown fox jumped over the lazy white dog"
```

The `lazy_dog_example.rb` is an example of using the Petri Dish library to solve a simple problem: Evolving a string to match "the quick brown fox jumped over the lazy white dog". This is a classic example of using a genetic algorithm to find a solution to a problem.

The genetic material in this case is the array of all lowercase letters and space. The target genes are the characters in the target string. The fitness function is defined as the cube of the sum of matches between the genes of a member and the target genes. This means that members with more matching characters will have a much higher fitness.

The parents for crossover are selected using a tournament selection function which picks the best 2 out of a random sample of 20% of the population. Crossover is performed at a random midpoint in the genes.

Mutation is implemented as a chance to replace a gene with a random gene from the genetic material. The mutation rate is set to 0.005, which means that on average, 0.5% of the genes in a member will mutate in each generation.

The end condition for the evolutionary process is when a member with genes exactly matching the target genes is found.

To run the example, simply execute the following command in your terminal:

```bash
bundle exec ruby examples/lazy_dog_example.rb
```
