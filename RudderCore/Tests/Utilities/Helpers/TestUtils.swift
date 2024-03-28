//
//  TestUtils.swift
//  RudderTests
//
//  Created by Pallab Maiti on 10/02/23.
//

import Foundation

func sleep(bySeconds: Int) {
    usleep(useconds_t(1000000 * bySeconds))
}
