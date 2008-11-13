// #define LOG_PDFPARSING_CALLBACKS


#ifdef LOG_PDFPARSING_CALLBACKS

	#warning LOG_PDFPARSING_CALLBACKS is enabled
	#define LOG_PDFPARSING_CALLBACKS_IMP \
	\
		NSLog( \
				@"%@ called on %@", \
				NSStringFromSelector( _cmd ), \
				self); \

#else

	#define LOG_PDFPARSING_CALLBACKS_IMP

#endif

			
