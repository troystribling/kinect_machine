#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"

#include <stdio.h>

#define IMAGE_WIDTH        640
#define IMAGE_HEIGHT       480
#define IMAGE_SIZE         IMAGE_WIDTH * IMAGE_HEIGHT
#define BYTES_PER_PIXEL    3
#define FRAMES_PER_SECOND  25
#define BIT_RATE           400000
#define GOP_SIZE           10
#define MAX_B_FRAMES       1

int main(int argc, char *argv[]) {
  FILE*               rgbFile;
  uint8_t*            rgbBuffer;
  int                 rgbBufferSize = BYTES_PER_PIXEL * IMAGE_WIDTH * IMAGE_HEIGHT;
  int                 rgbFileLen;
  uint8_t*            yuvBuffer;
  int                 yuvBufferSize = (BYTES_PER_PIXEL * IMAGE_WIDTH * IMAGE_HEIGHT) / 2;
  int                 frames;
  int                 curFrame;
  struct SwsContext*  rgbToYuvContext;
  AVFrame*            rgbFrame;
  AVFrame*            yuvFrame;
  AVCodec*            mpegCodec;
  AVCodecContext*     mpegCodecContext;

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

  // rgb buffer
  rgbBuffer = (uint8_t*) malloc(rgbBufferSize);
  rgbFrame = avcodec_alloc_frame();
  rgbFrame->data[0] = rgbBuffer;
  rgbFrame->data[1] = rgbFrame->data[0] + 1;
  rgbFrame->data[2] = rgbFrame->data[1] + 2;
  rgbFrame->linesize[0] = IMAGE_WIDTH;
  rgbFrame->linesize[1] = IMAGE_WIDTH;
  rgbFrame->linesize[2] = IMAGE_WIDTH;

  // yuv buffer
  yuvBuffer = (uint8_t*) malloc(yuvBufferSize);
  yuvFrame = avcodec_alloc_frame();
  yuvFrame->data[0] = yuvBuffer;
  yuvFrame->data[1] = yuvFrame->data[0] + IMAGE_SIZE;
  yuvFrame->data[2] = yuvFrame->data[1] + IMAGE_SIZE / 4;
  yuvFrame->linesize[0] = IMAGE_WIDTH;
  yuvFrame->linesize[1] = IMAGE_WIDTH / 2;
  yuvFrame->linesize[2] = IMAGE_WIDTH / 2;

  // codec
  mpegCodec = avcodec_find_encoder(CODEC_ID_MPEG2VIDEO);
  mpegCodecContext = avcodec_alloc_context2(CODEC_ID_MPEG2VIDEO);
  mpegCodecContext->bit_rate = BIT_RATE;
  mpegCodecContext->width = IMAGE_WIDTH;
  mpegCodecContext->height = IMAGE_HEIGHT;
  mpegCodecContext->time_base = (AVRational){1,FRAMES_PER_SECOND};
  mpegCodecContext->max_b_frames = MAX_B_FRAMES;
  mpegCodecContext->pix_fmt = PIX_FMT_YUV420P;

  // Register all formats and codecs
  av_register_all();

  // create RGB to YUV conversion context
  rgbToYuvContext = sws_getContext(IMAGE_WIDTH, IMAGE_HEIGHT, PIX_FMT_RGB24, IMAGE_WIDTH, IMAGE_HEIGHT, PIX_FMT_YUV420P, SWS_BICUBIC, NULL, NULL, NULL);

  // convet frames
  for (curFrame = 0; curFrame < frames; curFrame++) {
    fread(rgbBuffer, 1, rgbBufferSize, rgbFile);
    sws_scale(rgbToYuvContext, rgbFrame->data, rgbFrame->linesize, 0, IMAGE_HEIGHT, yuvFrame->data, yuvFrame->linesize);
    printf("CURRENT FRAME: %d, NEXT POSITION: %ld\n", curFrame + 1, ftell(rgbFile));
  }

  fclose(rgbFile);
  free(rgbBuffer);
  free(yuvBuffer);
  sws_freeContext(rgbToYuvContext);
  /*avcodec_close(mpegCodecContext);*/
  /*av_free(mpegCodecContext);*/
  av_free(rgbFrame);
  av_free(yuvFrame);

  return 0;
}
