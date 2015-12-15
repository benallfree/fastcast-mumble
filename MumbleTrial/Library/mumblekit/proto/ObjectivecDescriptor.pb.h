// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "Descriptor.pb.h"

@class ObjectiveCFileOptions;
@class ObjectiveCFileOptions_Builder;
@class PBDescriptorProto;
@class PBDescriptorProto_Builder;
@class PBDescriptorProto_ExtensionRange;
@class PBDescriptorProto_ExtensionRange_Builder;
@class PBEnumDescriptorProto;
@class PBEnumDescriptorProto_Builder;
@class PBEnumOptions;
@class PBEnumOptions_Builder;
@class PBEnumValueDescriptorProto;
@class PBEnumValueDescriptorProto_Builder;
@class PBEnumValueOptions;
@class PBEnumValueOptions_Builder;
@class PBFieldDescriptorProto;
@class PBFieldDescriptorProto_Builder;
@class PBFieldOptions;
@class PBFieldOptions_Builder;
@class PBFileDescriptorProto;
@class PBFileDescriptorProto_Builder;
@class PBFileDescriptorSet;
@class PBFileDescriptorSet_Builder;
@class PBFileOptions;
@class PBFileOptions_Builder;
@class PBMessageOptions;
@class PBMessageOptions_Builder;
@class PBMethodDescriptorProto;
@class PBMethodDescriptorProto_Builder;
@class PBMethodOptions;
@class PBMethodOptions_Builder;
@class PBServiceDescriptorProto;
@class PBServiceDescriptorProto_Builder;
@class PBServiceOptions;
@class PBServiceOptions_Builder;
@class PBSourceCodeInfo;
@class PBSourceCodeInfo_Builder;
@class PBSourceCodeInfo_Location;
@class PBSourceCodeInfo_Location_Builder;
@class PBUninterpretedOption;
@class PBUninterpretedOption_Builder;
@class PBUninterpretedOption_NamePart;
@class PBUninterpretedOption_NamePart_Builder;
#ifndef __has_feature
  #define __has_feature(x) 0 // Compatibility with non-clang compilers.
#endif // __has_feature

#ifndef NS_RETURNS_NOT_RETAINED
  #if __has_feature(attribute_ns_returns_not_retained)
    #define NS_RETURNS_NOT_RETAINED __attribute__((ns_returns_not_retained))
  #else
    #define NS_RETURNS_NOT_RETAINED
  #endif
#endif


@interface ObjectivecDescriptorRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
+ (id<PBExtensionField>) objectivecFileOptions;
@end

@interface ObjectiveCFileOptions : PBGeneratedMessage {
@private
  BOOL hasPackage_:1;
  BOOL hasClassPrefix_:1;
  NSString* package;
  NSString* classPrefix;
}
- (BOOL) hasPackage;
- (BOOL) hasClassPrefix;
@property (readonly, retain) NSString* package;
@property (readonly, retain) NSString* classPrefix;

+ (ObjectiveCFileOptions*) defaultInstance;
- (ObjectiveCFileOptions*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (ObjectiveCFileOptions_Builder*) builder;
+ (ObjectiveCFileOptions_Builder*) builder;
+ (ObjectiveCFileOptions_Builder*) builderWithPrototype:(ObjectiveCFileOptions*) prototype;
- (ObjectiveCFileOptions_Builder*) toBuilder;

+ (ObjectiveCFileOptions*) parseFromData:(NSData*) data;
+ (ObjectiveCFileOptions*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ObjectiveCFileOptions*) parseFromInputStream:(NSInputStream*) input;
+ (ObjectiveCFileOptions*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (ObjectiveCFileOptions*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (ObjectiveCFileOptions*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface ObjectiveCFileOptions_Builder : PBGeneratedMessage_Builder {
@private
  ObjectiveCFileOptions* result;
}

- (ObjectiveCFileOptions*) defaultInstance;

- (ObjectiveCFileOptions_Builder*) clear;
- (ObjectiveCFileOptions_Builder*) clone;

- (ObjectiveCFileOptions*) build;
- (ObjectiveCFileOptions*) buildPartial;

- (ObjectiveCFileOptions_Builder*) mergeFrom:(ObjectiveCFileOptions*) other;
- (ObjectiveCFileOptions_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (ObjectiveCFileOptions_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasPackage;
- (NSString*) package;
- (ObjectiveCFileOptions_Builder*) setPackage:(NSString*) value;
- (ObjectiveCFileOptions_Builder*) clearPackage;

- (BOOL) hasClassPrefix;
- (NSString*) classPrefix;
- (ObjectiveCFileOptions_Builder*) setClassPrefix:(NSString*) value;
- (ObjectiveCFileOptions_Builder*) clearClassPrefix;
@end

