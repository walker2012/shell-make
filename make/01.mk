(一).Makfile的规则
 --------------------------------------------------------------------------
 @brief 一个简单的makefile 规则
 Makefile 的简单规则：
 target ...: prereguisites ...
 	command
 	...

 	Target也就是一个目标文件，可以是Object File，也可以是执行文件。还可以是一个标签（Label），对于标签这种特性，在后续的“伪目标”章节中会有叙述。

 	prerequisites就是，要生成那个target所需要的文件或是目标。

 	command也就是make需要执行的命令,ps:和target有一个tab的距离。（任意的Shell命令）
	
	这里要说明一点的是，clean不是一个文件，它只不过是一个动作名字，有点像C语言中的lable一样，其冒号后什么也没有，那么，make就不会自动去找文件的依赖性，也就不会自动执行其后所定义的命令。要执行其后的命令，就要在make命令后明显得指出这个lable的名字。这样的方法非常有用，我们可以在一个makefile中定义不用的编译或是和编译无关的命令，比如程序的打包，程序的备份，等等。
----------------------------------------------------------------------------
edit : main.o kbd.o command.o display.o  insert.o search.o files.o utils.o
	cc -o edit main.o kbd.o command.o display.o /
insert.o search.o files.o utils.o

main.o : main.c defs.h
	cc -c main.c
kbd.o : kbd.c defs.h command.h
	cc -c kbd.c
command.o : command.c defs.h command.h
	cc -c command.c
display.o : display.c defs.h buffer.h
	cc -c display.c
insert.o : insert.c defs.h buffer.h
	cc -c insert.c
search.o : search.c defs.h buffer.h
	cc -c search.c
files.o : files.c defs.h buffer.h command.h
	cc -c files.c
utils.o : utils.c defs.h
	cc -c utils.c
clean :
	rm edit main.o kbd.o command.o display.o /
insert.o search.o files.o utils.o
#这里要说明一点的是，clean不是一个文件，它只不过是一个动作名字，有点像C语言中的lable一样，其冒号后什么也没有，那么，make就不会自动去找文件的依赖性，也就不会自动执行其后所定义的命令。要执行其后的命令，就要在make命令后明显得指出这个lable的名字。这样的方法非常有用，我们可以在一个makefile中定义不用的编译或是和编译无关的命令，比如程序的打包，程序的备份，等等。
二.makefile中使用变量

	对于经常在makefile中出现的一些字符串或者文件，我们可以使用变量来进行定义，每次在引用某些文件或者字符串的时候直接使用变量就可以了,使用$(变量);
	for example:
	objects = main.o kbd.o command.o display.o /
	              insert.o search.o files.o utils.o
	edit : $(objects)
		cc -o edit $(objects)
	main.o : main.c defs.h
		cc -c main.c
	kbd.o : kbd.c defs.h command.h
		cc -c kbd.c
	command.o : command.c defs.h command.h
		cc -c command.c
	display.o : display.c defs.h buffer.h
		cc -c display.c
	insert.o : insert.c defs.h buffer.h
		cc -c insert.c
	search.o : search.c defs.h buffer.h
		cc -c search.c
	files.o : files.c defs.h buffer.h command.h
		cc -c files.c
	utils.o : utils.c defs.h
		cc -c utils.c 
	clean :
		rm edit $(objects)
#ps:cc编译的时候不需要头文件，之需要把头文件放到依赖文件列表就行了，当头文件发生变化的会重新执行编译命令，编译器会将#include的文件自动包含进来
#ps:make 是如何工作的
	1、make会在当前目录下找名字叫“Makefile”或“makefile”的文件。
	2、如果找到，它会找文件中的第一个目标文件（target），在上面的例子中，他会找到“edit”这个文件，并把这个文件作为最终的目标文件。
	3、如果edit文件不存在，或是edit所依赖的后面的 .o 文件的文件修改时间要比edit这个文件新，那么，他就会执行后面所定义的命令来生成edit这个文件。
	4、如果edit所依赖的.o文件也存在，那么make会在当前文件中找目标为.o文件的依赖性，如果找到则再根据那一个规则生成.o文件。（这有点像一个堆栈的过程）
	5、当然，你的C文件和H文件是存在的啦，于是make会生成 .o 文件，然后再用 .o 文件生命make的终极任务，也就是执行文件edit了。
 
	
三.让make自动推导

GNU的make很强大，它可以自动推导文件以及文件依赖关系后面的命令，于是我们就没必要去在每一个[.o]文件后都写上类似的命令，因为，我们的make会自动识别，并自己推导命令。
只要make看到一个[.o]文件，它就会自动的把[.c]文件加在依赖关系中，如果make找到一个whatever.o，那么whatever.c，就会是whatever.o的依赖文件。并且 cc -c whatever.c 也会被推导出来，于是，我们的makefile再也不用写得这么复杂。我们的是新的makefile又出炉了。


objects = main.o kbd.o command.o display.o /
insert.o search.o files.o utils.o

	edit : $(objects)
		cc -o edit $(objects)

	main.o : defs.h
	kbd.o : defs.h command.h
	command.o : defs.h command.h
	display.o : defs.h buffer.h
	insert.o : defs.h buffer.h
	search.o : defs.h buffer.h
	files.o : defs.h buffer.h command.h
	utils.o : defs.h

	.PHONY : clean
	clean :
		rm edit $(objects)
#这种方法，也就是make的“隐晦规则”。上面文件内容中，“.PHONY”表示，clean是个伪目标文件。
	更为稳健的做法是：
	.PHONY : clean
	clean :
		-rm edit $(objects)
	前面说过，.PHONY意思表示clean是一个“伪目标”，。而在rm命令前面加了一个小减号的意思就是，也许某些文件出现问题，但不要管，继续做后面的事。当然，clean的规则不要放在文件的开头，不然，这就会变成make的默认目标，相信谁也不愿意这样。不成文的规矩是——“clean从来都是放在文件的最后”。



四.Makefile 总述


1)、Makefile里有什么？

Makefile里主要包含了五个东西：显式规则、隐晦规则、变量定义、文件指示和注释。

1、显式规则。显式规则说明了，如何生成一个或多的的目标文件。这是由Makefile的书写者明显指出，要生成的文件，文件的依赖文件，生成的命令。

2、隐晦规则。由于我们的make有自动推导的功能，所以隐晦的规则可以让我们比较粗糙地简略地书写Makefile，这是由make所支持的。

3、变量的定义。在Makefile中我们要定义一系列的变量，变量一般都是字符串，这个有点你C语言中的宏，当Makefile被执行时，其中的变量都会被扩展到相应的引用位置上。

4、文件指示。其包括了三个部分，一个是在一个Makefile中引用另一个Makefile，就像C语言中的include一样；另一个是指根据某些情况指定Makefile中的有效部分，就像C语言中的预编译#if一样；还有就是定义一个多行的命令。有关这一部分的内容，我会在后续的部分中讲述。

5、注释。Makefile中只有行注释，和UNIX的Shell脚本一样，其注释是用“#”字符，这个就像C/C++中的“//”一样。如果你要在你的Makefile中使用“#”字符，可以用反斜框进行转义，如：“/#”。

最后，还值得一提的是，在Makefile中的命令，必须要以[Tab]键开始。


2)、Makefile的文件名

默认的情况下，make命令会在当前目录下按顺序找寻文件名为“GNUmakefile”、“makefile”、“Makefile”的文件，找到了解释这个文件。在这三个文件名中，最好使用“Makefile”这个文件名，因为，这个文件名第一个字符为大写，这样有一种显目的感觉。最好不要用“GNUmakefile”，这个文件是GNU的make识别的。有另外一些make只对全小写的“makefile”文件名敏感，但是基本上来说，大多数的make都支持“makefile”和“Makefile”这两种默认文件名。

当然，你可以使用别的文件名来书写Makefile，比如：“Make.Linux”，“Make.Solaris”，“Make.AIX”等，如果要指定特定的Makefile，你可以使用make的“-f”和“--file”参数，如：make -f Make.Linux或make --file Make.AIX。





3)、引用其它的Makefile

	在Makefile使用include关键字可以把别的Makefile包含进来，这很像C语言的#include，被包含的文件会原模原样的放在当前文件的包含位置。include的语法是：
	
	include <filename>
	
	filename可以是当前操作系统Shell的文件模式（可以保含路径和通配符）
	
	在include前面可以有一些空字符，但是绝不能是[Tab]键开始。include和<filename>可以用一个或多个空格隔开。举个例子，你有这样几个Makefile：a.mk、b.mk、c.mk，还有一个文件叫foo.make，以及一个变量$(bar)，其包含了e.mk和f.mk，那么，下面的语句：
	
	include foo.make *.mk $(bar)
	
		等价于：
	
		include foo.make a.mk b.mk c.mk e.mk f.mk
	
		make命令开始时，会把找寻include所指出的其它Makefile，并把其内容安置在当前的位置。就好像C/C++的#include指令一样。如果文件都没有指定绝对路径或是相对路径的话，make会在当前目录下首先寻找，如果当前目录下没有找到，那么，make还会在下面的几个目录下找：
	
		1、如果make执行时，有“-I”或“--include-dir”参数，那么make就会在这个参数所指定的目录下去寻找。
		2、如果目录<prefix>/include（一般是：/usr/local/bin或/usr/include）存在的话，make也会去找。
	
		如果有文件没有找到的话，make会生成一条警告信息，但不会马上出现致命错误。它会继续载入其它的文件，一旦完成makefile的读取，make会再重试这些没有找到，或是不能读取的文件，如果还是不行，make才会出现一条致命信息。如果你想让make不理那些无法读取的文件，而继续执行，你可以在include前加一个减号“-”。如：
	
		-include <filename>
		其表示，无论include过程中出现什么错误，都不要报错继续执行。和其它版本make兼容的相关命令是sinclude，其作用和这一个是一样的。


	5)、make的工作方式

		GNU的make工作时的执行步骤入下：（想来其它的make也是类似）

		1、读入所有的Makefile。
		2、读入被include的其它Makefile。
		3、初始化文件中的变量。
		4、推导隐晦规则，并分析所有规则。
		5、为所有的目标文件创建依赖关系链。
		6、根据依赖关系，决定哪些目标要重新生成。
		7、执行生成命令。

		1-5步为第一个阶段，6-7为第二个阶段。第一个阶段中，如果定义的变量被使用了，那么，make会把其展开在使用的位置。但make并不会完全马上展开，make使用的是拖延战术，如果变量出现在依赖关系的规则中，那么仅当这条依赖被决定要使用了，变量才会在其内部展开。




