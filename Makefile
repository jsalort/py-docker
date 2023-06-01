all:
	docker tag jsalort/texlive:2023_intel jsalort/texlive:latest
	docker build --platform linux/amd64 -t jsalort/py:3.10_intel .
	docker tag jsalort/py:3.10_intel jsalort/py:latest

push:
	docker tag jsalort/py:3.10_intel jsalort/py:3.10
	docker tag jsalort/py:3.10_intel jsalort/py:latest
	docker push jsalort/py:3.10_intel
	docker push jsalort/py:latest

arm:
	docker tag jsalort/texlive:2023_arm64 jsalort/texlive:latest
	docker build --platform arm64 -t jsalort/py:3.10_arm64 .
	docker tag jsalort/py:3.10_arm64 jsalort/py:latest

push_arm:
	docker push jsalort/py:3.10_arm64