////
////  GapTaskSchedulerTester.swift
////  GapTaskSchedulerDemo
////
////  Created by Cheng Zhang on 1/13/18.
////  Copyright © 2018 Cheng Zhang. All rights reserved.
////
//
import UIKit

public class GapTaskSchedulerTester: NSObject {
    fileprivate enum Constant {
        static let gap = 0.01
    }
    fileprivate var count = 0
    fileprivate var gapTaskScheduler: GapTaskScheduler = {
        return GapTaskScheduler(gap: Constant.gap)
    }()

    func testTasksInOneGap() {
        // Schedule task now
        gapTaskScheduler.schedule { [weak self] in
            self?.incrementCount()
        }
        // Expected `count` = 1 now
        assertCount(equalsTo: 1)

        // Schedule task now again. As actualGap between first/second tasks < `gap`(0.01 sec), second task will be scheduled to next gap cycle
        gapTaskScheduler.schedule { [weak self] in
            self?.incrementCount()
        }
        // Expected `count` = 1 now
        assertCount(equalsTo: 1)
        // Expected `count` = 2 after 0.01 sec
        assertCount(equalsTo: 2, after: 0.010)
    }

    func testTasksInMultiGaps() {
        // Schedule task now. Expected `count` = 1 now
        gapTaskScheduler.schedule { [weak self] in
            self?.incrementCount()
        }
        assertCount(equalsTo: 1)

        // Tasks in `gap` [0, 0.01] sec should be delayed/merged and executed only once
        scheduleCounterTask(after: 0.003)
        scheduleCounterTask(after: 0.004)
        scheduleCounterTask(after: 0.005)
        // Expected `count` = 1 now
        assertCount(equalsTo: 1)
        // Expected `count` = 2 after 0.01 sec
        assertCount(equalsTo: 2, after: 0.010)

        // Tasks in `gap` [0.01, 0.02] sec should be delayed/merged and executed only once
        scheduleCounterTask(after: 0.013)
        scheduleCounterTask(after: 0.014)
        scheduleCounterTask(after: 0.015)
        // Expected `count` = 2 after 0.013 sec
        assertCount(equalsTo: 2, after: 0.013)
        // Expected `count` = 3 after 0.02 sec
        assertCount(equalsTo: 3, after: 0.020)

        // Wait 0.02 secs for async tests
    }

    func _testTasksInCombinedGaps() {
        count = 0
        
        // Schedule task now
        gapTaskScheduler.schedule { [weak self] in
            self?.incrementCount()
        }
        // Expected `count` = 1 now
        assertCount(equalsTo: 1)

        // Schedule task now again. As actualGap between first/second tasks < `gap`(0.01 sec), second task will be scheduled to next gap cycle
        gapTaskScheduler.schedule { [weak self] in
            self?.incrementCount()
        }
        // Expected `count` = 1 now
        assertCount(equalsTo: 1)
        // Expected `count` = 2 after 0.01 sec
        assertCount(equalsTo: 2, after: 0.010)

        // Tasks in `gap` [0, 0.01] sec should be delayed/merged and executed only once
        scheduleCounterTask(after: 0.003)
        scheduleCounterTask(after: 0.004)
        scheduleCounterTask(after: 0.005)
        // Expected `count` = 1 now
        assertCount(equalsTo: 1)
        // Expected `count` = 2 after 0.01 sec
        assertCount(equalsTo: 2, after: 0.010)

        // Tasks in `gap` [0.01, 0.02] sec should be delayed/merged and executed only once
        scheduleCounterTask(after: 0.013)
        scheduleCounterTask(after: 0.014)
        scheduleCounterTask(after: 0.015)
        // Expected `count` = 3 after 0.02 sec
        assertCount(equalsTo: 3, after: 0.020)

        // Schedule task at 0.032 sec, as last execution date is 0.020 sec, it should be executed immediately
        scheduleCounterTask(after: 0.032)
        // Expected `count` = 4 after 0.032 sec
        assertCount(equalsTo: 4, after: 0.032)
        // Expected `count` = 4 after 0.040 sec
        assertCount(equalsTo: 4, after: 0.040)
    }

    func testTasksInCombinedGaps() {
        _testTasksInCombinedGaps()
        // Wait 0.04 secs for async tests
    }

    /**
     Test multiple cycles of combined gaps
     */
    func testTasksInComplexCombinedGaps() {
        _testTasksInCombinedGaps()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.040 + 0.010 * 6) { [weak self] in
            self?._testTasksInCombinedGaps()
        }
    }
}

fileprivate extension GapTaskSchedulerTester {
    func incrementCount() {
        count += 1
        print("\(Date()) Executed `\(#function)`: count = \(count)")
    }
    
    func assertCount(equalsTo count: Int, after delayTime: TimeInterval? = nil) {
        // Sync execution
        guard let delayTime = delayTime else {
            assert(count == self.count, "\(Date()) Error - actualCount = \(self.count); expectedCount = \(count)")
            return
        }
        // Async execution
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
            assert(count == self.count, "\(Date()) Error - actualCount = \(self.count); expectedCount = \(count)")
        }
    }
    
    func scheduleCounterTask(after delayTime: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
            self.gapTaskScheduler.schedule {
                self.incrementCount()
            }
        }
    }
}


