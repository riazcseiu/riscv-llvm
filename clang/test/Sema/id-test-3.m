// RUN: clang -rewrite-test %s | clang

@protocol P
- (id<P>) Meth: (id<P>) Arg;
@end

@interface INTF<P>
- (id<P>)IMeth;
@end

@implementation INTF
- (id<P>)IMeth { return [(id<P>)self Meth: (id<P>)0]; }
- (id<P>) Meth : (id<P>) Arg {}
@end
