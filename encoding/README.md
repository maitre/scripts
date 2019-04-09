Various scripts related to video encoding:

- activenc.sh
A script to automatically encode video files to iTunes-friendly
MP4. The idea was to drop videos into one place, and the next day they would
be re-encoded and ready for iTunes. The focus eventually changed to speedy
re-encoding of multiple files, using simple threading. The logic is very
lazy, and easy to break. But used correctly, it does what it is supposed to.

Requires mencoder with x264 and faac codecs (and libav, naturally).

