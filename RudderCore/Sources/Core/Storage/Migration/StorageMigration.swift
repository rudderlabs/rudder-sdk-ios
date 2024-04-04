//
//  StorageMigration.swift
//  Rudder
//
//  Created by Pallab Maiti on 02/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

class StorageMigration {
    let storageMigrator: StorageMigrator
    
    init(storageMigrator: StorageMigrator) {
        self.storageMigrator = storageMigrator
    }
    
    func migrate() {
        storageMigrator.migrate()
    }
}
