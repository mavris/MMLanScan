//
//  MacFinder.m
//  MacFinder
//
//  Created by Michael Mavris on 08/06/16.
//  Copyright © 2016 Miksoft. All rights reserved.
//
#import "MacFinder.h"

@implementation MacFinder

+(NSString*)ip2mac:(NSString*)strIP {
    
    const char *ip = [strIP UTF8String];
    
    int  found_entry = 0;
    int nflag=0;
    
    NSString *mAddr = nil;
    u_long addr = inet_addr(ip);
    int mib[6];
    size_t needed;
    char *host, *lim, *buf, *next;
    struct rt_msghdr *rtm;
    struct sockaddr_inarp *sin;
    struct sockaddr_dl *sdl;
    extern int h_errno;
    struct hostent *hp;
    
    mib[0] = CTL_NET;
    mib[1] = PF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_INET;
    mib[4] = NET_RT_FLAGS;
    mib[5] = RTF_LLINFO;
    
    if (sysctl(mib, 6, NULL, &needed, NULL, 0) < 0)
        err(1, "route-sysctl-estimate");
    if ((buf = malloc(needed)) == NULL)
        err(1, "malloc");
    if (sysctl(mib, 6, buf, &needed, NULL, 0) < 0)
        err(1, "actual retrieval of routing table");
    
    lim = buf + needed;
    
    for (next = buf; next < lim; next += rtm->rtm_msglen) {
        rtm = (struct rt_msghdr *)next;
        sin = (struct sockaddr_inarp *)(rtm + 1);
        sdl = (struct sockaddr_dl *)(sin + 1);
        if (addr) {
            if (addr != sin->sin_addr.s_addr)
                continue;
            found_entry = 1;
        }
        if (nflag == 0)
            hp = gethostbyaddr((caddr_t)&(sin->sin_addr),
                               sizeof sin->sin_addr, AF_INET);
        else
            hp = 0;
        if (hp)
            host = hp->h_name;
        else {
            host = "?";
            if (h_errno == TRY_AGAIN)
                nflag = 1;
        }
        
        
        if (sdl->sdl_alen) {
            
            u_char *cp =(u_char*)LLADDR(sdl);
            
            mAddr = [NSString stringWithFormat:@"%x:%x:%x:%x:%x:%x", cp[0], cp[1], cp[2], cp[3], cp[4], cp[5]];
        }
        else
            mAddr = nil;
    }
    
    
    if (!mAddr) {
        return nil;
    }
    
    //Fixing the issue with 0 in MAC Address (eg. 00 will be displayed as 0. We fix this here).
    NSArray *macArray = [mAddr componentsSeparatedByString:@":"];
    
    NSMutableString *mutStr = [[NSMutableString alloc] init];
    
    for (int i=0; i < [macArray count]; i++) {
        NSString *str = [macArray objectAtIndex:i];
        if ([str length]<2) {
            [mutStr appendString:@"0"];
        }
        
        NSString *strToAppend = i < [macArray count] - 1 ? [NSString stringWithFormat:@"%@:",str] : str;
        
        [mutStr appendString:strToAppend];
    }
    
    if (found_entry == 0) {
        
        return nil;
    }
    else {
        
        return mutStr;
    }
}
@end