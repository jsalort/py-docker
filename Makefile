all:
	docker build --platform x86_64 -t jsalort/py:3.9_intel .
	docker tag jsalort/py:3.9_intel jsalort/py:latest

push:
	docker tag jsalort/py:3.9_intel jsalort/py:3.9
	docker tag jsalort/py:3.9_intel jsalort/py:latest
	docker push jsalort/py:3.9
	docker push jsalort/py:latest

arm:
	docker build --platform arm64 -t jsalort/py:3.9_arm64 .
	docker tag jsalort/py:3.9_arm64 jsalort/py:latest
