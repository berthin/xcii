VERSION=`python3 -c "import xcii; print(xcii.__version__)"`

xcii.1: xcii.1.md
	pandoc xcii.1.md -s -t man -o xcii.1 -V header:"Version $(VERSION), `date +%Y-%m-%d`"
