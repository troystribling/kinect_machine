#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"

#include <stdio.h>

#define IMAGE_WIDTH        640
#define IMAGE_HEIGHT       480
#define BYTES_PER_PIXEL    3
#define FRAMES_PER_SECOND  30

int main(int argc, char *argv[]) {
  FILE*               rgbFile;
  char*               rgbBuffer;
  int                 rgbBufferSize = BYTES_PER_PIXEL * IMAGE_WIDTH * IMAGE_HEIGHT;
  int                 rgbFileLen;
  char*               yuvBuffer;
  int                 yuvBufferSize = (BYTES_PER_PIXEL * IMAGE_WIDTH * IMAGE_HEIGHT) / 2;
  int                 frames;
  int                 curFrame;
  struct SwsContext*  pRgbToYuvContext;
  AVFrame*            rgbFrame;
  AVFrame*            yuvFrame;

  // check args
  if(argc < 2) {
    printf("NEED AN RGB FILE NAME\n");
    exit(-1);
  }

	// read file
  printf("ENCODING RGB FILE: %s\n", argv[1]);
  rgbFile = fopen(argv[1], "rb");
  if (rgbFile == NULL) {
    printf("ERROR OPENING FILE\n");
    exit(-1);
  }
  fseek(rgbFile, 0, SEEK_END);
  rgbFileLen = ftell(rgbFile);
  fseek(rgbFile, 0, SEEK_SET);
  frames = rgbFileLen / rgbBufferSize;
  printf("RGB FILE LENGTH: %d BYTES\n", rgbFileLen);
  printf("FRAMES: %d\n", frames);

  // buffers
  rgbBuffer = (char*) malloc(rgbBufferSize);
  yuvBuffer = (char*) malloc(yuvBufferSize);

  // Register all formats and codecs
  av_register_all();

  // create RGB to YUV conversion context
  pRgbToYuvContext = sws_getContext(IMAGE_WIDTH, IMAGE_HEIGHT, PIX_FMT_RGB24, IMAGE_WIDTH, IMAGE_HEIGHT, PIX_FMT_YUV420P, SWS_BICUBIC, NULL, NULL, NULL);

  // convet frames
  for (curFrame = 0; curFrame < frames; curFrame++) {
    fread(rgbBuffer, 1, rgbBufferSize, rgbFile);
    printf("CURRENT FRAME: %d, NEXT POSITION: %ld\n", curFrame, ftell(rgbFile));
  }

  fclose(rgbFile);
  free(rgbBuffer);
  free(yuvBuffer);

  return 0;
}
