#import "RSDataResidencyManager.h"

@implementation RSDataResidencyManager

-(instancetype)initWithRSConfig:(RSConfig*) rudderConfig {
    self = [super init];
    if(self) {
        self->rudderConfig = rudderConfig;
    }
    return self;
}

- (void)setDataResidencyUrlFromSourceConfig:(RSServerConfigSource*) sourceConfig {
    if(sourceConfig == nil) {
        return;
    }

    NSArray * residenceDataPlanes;
    switch(rudderConfig.dataResidencyServer) {
        case EU:
            residenceDataPlanes = [sourceConfig.dataPlanes objectForKey:@"EU"];
        // If EU is missing from the sourceConfig response we should fallback to the US, hence the break is not added here.
        default:
            if (residenceDataPlanes != nil)
                break;
            residenceDataPlanes = [sourceConfig.dataPlanes objectForKey:@"US"];
    }
    
    if(residenceDataPlanes == nil || [residenceDataPlanes count] == 0)
        return;

    for (NSDictionary* residenceDataPlane in residenceDataPlanes) {
        if([[residenceDataPlane objectForKey:@"default"] boolValue]) {
            self->dataResidencyUrl = [RSUtils appendSlashToUrl:[residenceDataPlane objectForKey:@"url"]];
        }
    }
    return;
}

- (NSString*) getDataPlaneUrl {
    return self->dataResidencyUrl == nil ? self->rudderConfig.dataPlaneUrl : self->dataResidencyUrl;
}

@end
