//
//  TCPBenchmarker.swift
//  swift-client-v2
//
//  Created by Ethan Petuchowski on 11/4/15.
//  Copyright © 2015 Ethanp. All rights reserved.
//

import Foundation

/**
 What this does is
 
 1. Connects to `syncCount` TCP servers at ports
 `BASE_PORT...BASE_PORT+syncCount-1`
 2. Collects performance data about those TCP connections
 3. Uploads the data to the Sinatra `dataserver.rb`
 */
class TcpBenchmarker: ResultMgr {
    
    /** Array of connections to each TCP server from which we shall
     concurrently download
     */
    var conns = [EventedConn]()
    
    /** Array of benchmark datapoints for each TCP server.
     Once these are collected they will be automatically uploaded
     to the DataServer
     */
    var results = [Results]()
    
    /** how many TCP servers to connect and download concurrently from */
    var syncCount: Int?
    
    /** how many TCP servers we have finished collecting
     performance data for
     */
    var done = 0
    
    init(syncCount: Int) {
        self.syncCount = syncCount
        for _ in 1...syncCount {
            conns.append(EventedConn(resultMgr: self))
            results.append([:])
        }
    }
    
    /**
     Asynchronous method
     
     1. initiates `syncCount` connections
     2. collects performance benchmarks
     3. uploads collected data to `dataserver.rb`
     */
    func collectAndUploadResults() {
        for i in 1...syncCount! {
            self.conns[i-1].connect("localhost", port:BASE_PORT+i-1, size: 5)
        }
    }
    
    // TODO: if the server has too much data, this doesn't happen at the right time
    // I should just make it read until it can't read no more
    func addResult(result: Results, forIndex i: Int) {
        results[i] = result
        print("added result \(result) to \(i)")
        done++
        if done == syncCount {
            print("got a bunch of results for ya, see: \(results)")
            // TODO: this is where I upload the results to the DataServer
        }
    }
}