@echo off
setlocal

call %~dp0asteroids\build.cmd
call %~dp0breakout\build.cmd
call %~dp0pong\build.cmd

endlocal