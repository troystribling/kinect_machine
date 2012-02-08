#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"

#include <stdio.h>

#define IMAGE_WIDTH        640
#define IMAGE_HEIGHT       480
#define BYTES_PER_PIXEL    3
#define FRAMES_PER_SECOND  30

int main(int argc, char *argv[]) {
  AVFormatContext *pFormatCtx;
  int             i, videoStream;
  AVCodecContext* pCodecCtx;
  AVCodec*        pCodec;
  AVFrame*        pFrame;
  AVFrame*        pFrameRGB;
  AVPacket        packet;
  int             frameFinished;
  int             numBytes;
  char*           buffer;
  int             frames;
  int             fileLen;
  FILE*           file;

  // check args
  if(argc < 2) {
    printf("NEED AN RGB FILE NAME\n");
    exit(-1);
  }

	// read file
  printf("ENCODING RGB FILE: %s\n", argv[1]);
  /*buffer = (char*)malloc(IMAGE_WIDTH*IMAGE_HEIGHT);*/
  file = fopen(argv[1], "rb");
  if (file == NULL) {
    printf("ERROR OPENING FILE\n");
    exit(-1);
  }
  fseek(file, 0, SEEK_END);
  fileLen=ftell(file);
  fseek(file, 0, SEEK_SET);
  frames = fileLen / (BYTES_PER_PIXEL * IMAGE_WIDTH * IMAGE_HEIGHT);
  printf("FILE LENGTH: %d BYTES\n", fileLen);
  printf("FRAMES: %d\n", frames);

  // Register all formats and codecs
  av_register_all();

  // Open video file
  /*if(av_open_input_file(&pFormatCtx, argv[1], NULL, 0, NULL) != 0)*/
    /*return -1; // Couldn't open file*/

  // Retrieve stream information
  /*if(av_find_stream_info(pFormatCtx) < 0)*/
    /*return -1; // Couldn't find stream information*/

  // Dump information about file onto standard error
  /*dump_format(pFormatCtx, 0, argv[1], 0);*/

  // Find the first video stream
  /*videoStream=-1;*/
  /*for(i=0; i<pFormatCtx->nb_streams; i++)*/
    /*if(pFormatCtx->streams[i]->codec->codec_type==CODEC_TYPE_VIDEO) {*/
      /*videoStream=i;*/
      /*break;*/
    /*}*/
  /*if(videoStream==-1)*/
    /*return -1; // Didn't find a video stream*/

  // Get a pointer to the codec context for the video stream
  /*pCodecCtx=pFormatCtx->streams[videoStream]->codec;*/

  // Find the decoder for the video stream
  /*pCodec=avcodec_find_decoder(pCodecCtx->codec_id);*/
  /*if(pCodec==NULL) {*/
    /*fprintf(stderr, "Unsupported codec!\n");*/
    /*return -1; // Codec not found*/
  /*}*/
  // Open codec
  /*if(avcodec_open(pCodecCtx, pCodec)<0)*/
    /*return -1; // Could not open codec*/

  // Allocate video frame
  /*pFrame=avcodec_alloc_frame();*/

  // Allocate an AVFrame structure
  /*pFrameRGB=avcodec_alloc_frame();*/
  /*if(pFrameRGB==NULL)*/
    /*return -1;*/

  // Determine required buffer size and allocate buffer
  /*numBytes=avpicture_get_size(PIX_FMT_RGB24, pCodecCtx->width,*/
						/*pCodecCtx->height);*/
  /*buffer=(uint8_t *)av_malloc(numBytes*sizeof(uint8_t));*/

  // Assign appropriate parts of buffer to image planes in pFrameRGB
  // Note that pFrameRGB is an AVFrame, but AVFrame is a superset
  // of AVPicture
  /*avpicture_fill((AVPicture *)pFrameRGB, buffer, PIX_FMT_RGB24,*/
		 /*pCodecCtx->width, pCodecCtx->height);*/

  // Read frames and save first five frames to disk
  /*i=0;*/
  /*while(av_read_frame(pFormatCtx, &packet)>=0) {*/
    // Is this a packet from the video stream?
    /*if(packet.stream_index==videoStream) {*/
      // Decode video frame
      /*avcodec_decode_video(pCodecCtx, pFrame, &frameFinished,*/
				 /*packet.data, packet.size);*/

      // Did we get a video frame?
      /*if(frameFinished) {*/
	// Convert the image from its native format to RGB
	/*img_convert((AVPicture *)pFrameRGB, PIX_FMT_RGB24,*/
                    /*(AVPicture*)pFrame, pCodecCtx->pix_fmt, pCodecCtx->width,*/
                    /*pCodecCtx->height);*/

	// Save the frame to disk
	/*if(++i<=5)*/
		/*SaveFrame(pFrameRGB, pCodecCtx->width, pCodecCtx->height,*/
				/*i);*/
      /*}*/
    /*}*/

    // Free the packet that was allocated by av_read_frame
    /*av_free_packet(&packet);*/
  /*}*/

  // Free the RGB image
  /*av_free(buffer);*/
  /*av_free(pFrameRGB);*/

  // Free the YUV frame
  /*av_free(pFrame);*/

  // Close the codec
  /*avcodec_close(pCodecCtx);*/

  fclose(file);
  return 0;
}
