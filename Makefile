all:
	docker tag jsalort/texlive:2024_intel jsalort/texlive:latest
	docker build --platform linux/amd64 -t jsalort/py:3.12_intel .
	docker tag jsalort/py:3.12_intel jsalort/py:latest

push:
	docker tag jsalort/py:3.12_intel jsalort/py:3.12
	docker tag jsalort/py:3.12_intel jsalort/py:latest
	docker push jsalort/py:3.12_intel
	docker push jsalort/py:latest

arm:
	docker tag jsalort/texlive:2024_arm64 jsalort/texlive:latest
	docker build --platform linux/arm64 -t jsalort/py:3.12_arm64 .
	docker tag jsalort/py:3.12_arm64 jsalort/py:latest

push_arm:
	docker push jsalort/py:3.12_arm64
