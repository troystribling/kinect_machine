#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"

#include <stdio.h>

#define IMAGE_WIDTH        640
#define IMAGE_HEIGHT       480
#define BYTES_PER_PIXEL    3
#define FRAMES_PER_SECOND  30

int main(int argc, char *argv[]) {
  char*               rgbBuffer;
  int                 frames;
  int                 rgbFileLen;
  FILE*               rgbFile;
  struct SwsContext*  pRgbToYuvContext;

  // check args
  if(argc < 2) {
    printf("NEED AN RGB FILE NAME\n");
    exit(-1);
  }

	// read file
  printf("ENCODING RGB FILE: %s\n", argv[1]);
  /*buffer = (char*)malloc(IMAGE_WIDTH*IMAGE_HEIGHT);*/
  rgbFile = fopen(argv[1], "rb");
  if (rgbFile == NULL) {
    printf("ERROR OPENING FILE\n");
    exit(-1);
  }
  fseek(rgbFile, 0, SEEK_END);
  rgbFileLen = ftell(rgbFile);
  fseek(rgbFile, 0, SEEK_SET);
  frames = rgbFileLen / (BYTES_PER_PIXEL * IMAGE_WIDTH * IMAGE_HEIGHT);
  printf("RGB FILE LENGTH: %d BYTES\n", rgbFileLen);
  printf("FRAMES: %d\n", frames);

  // Register all formats and codecs
  av_register_all();

  // create RGB to YUV conversion context
  pRgbToYuvContext = sws_getContext(IMAGE_WIDTH, IMAGE_HEIGHT, PIX_FMT_RGB24, IMAGE_WIDTH, IMAGE_HEIGHT, PIX_FMT_YUV420P, SWS_BICUBIC, NULL, NULL, NULL);

  // convet frames
  for (int i =0; i < frames; i++) {
    sws_scale();
  }

  fclose(rgbFile);

  return 0;
}
