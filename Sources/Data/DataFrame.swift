//
//  DataFrame.swift
//  BoikoML
//
//  Created by Luis Eduardo Boiko Ferreira on 12/06/2018.
//  Copyright © 2018 Luis Eduardo Boiko Ferreira. All rights reserved.
//

import Foundation

public class DataFrame<T> {
    
    private var inputData : [[T]]
    private var data: [Int: [Any]] = [:]
    private var header : Header<Any>
    private var metaAttributeIndex : Int
    
    public init(inputData: [[T]], header: Header<Any>, metaAttributeIndex : Int) {
        self.inputData = inputData
        self.header = header
        self.metaAttributeIndex = metaAttributeIndex
        self.populateDataFrame()
    }
    
    // MARK: Internal functions
    
    private func populateDictKeys() {
        for i in 0..<self.inputData[0].count {
            self.data[i] = []
        }
    }
    
    private func populateDataFrame() {
        self.populateDictKeys()
        for instance in self.inputData {
            for i in 0..<instance.count {
//                self.data[i]!.append(instance[i])
                if instance[i] is Int {
//                    self.data[i]?.append(instance[i])
                    self.data[i]!.append(Double(instance[i] as! Int))
                } else if instance[i] is Double{
                    self.data[i]!.append(instance[i] as! Double)
                } else {
                    self.data[i]!.append(instance[i] as! String)
                }
            }
        }
        self.updateDataTypes()
        
    }
    
    // MARK: Meta attribute related
    
    public func getMetaName(index: Int) -> String {
        return self.header.featureNameAtIndex(index: index)
    }
    
    public func getMetaIndex() -> Int {
        return self.metaAttributeIndex
    }
    
    // MARK: Utils
    
    public func getPossibleValues(key : Int) -> [AnyHashable : Int] {
        return NSCountedSet(array: Array(self.data[key]!)).dictionary
    }
    
    public func getHeader() -> [Feature<Any>] {
        return self.header.header()
    }
    
    public func shape() -> [Int] {
        return [self.data.count, self.data[0]!.count]
    }
    
    
    
    private func getTrainingInstanceLimit(percent: Double) -> Int {
        return Int(Double(self.shape()[1]) * percent)
    }
    
    // This function receive the percent [0, 1] of the trainSet and return
    
    public func trainTestSplit(percent : Double) -> [String : DataFrame] {
        
        let limit = self.getTrainingInstanceLimit(percent: percent)
    
        
        var trainSlice: [Int: [Any]] = [:]
        var testSlice: [Int: [Any]] = [:]
        for i in 0..<self.data.count {
            trainSlice[i]?.append(self.data[i]![0 ..< limit])
            testSlice[i]?.append(self.data[i]![limit ..< self.shape()[1]])
        }
    
        let train = self.cloneDf()
        let test = self.cloneDf()
        
        
        train.setData(data: trainSlice)
        test.setData(data: testSlice)
        
        return ["train" : train,
                "test" : test]
    }
    
    private func cloneDf() -> DataFrame {
        return DataFrame(inputData: self.inputData, header: self.header, metaAttributeIndex: self.metaAttributeIndex)
    }
    
    public func setData(data: [Int : [Any]]) {
        self.data = data
    }
    
    private func updateDataTypes() {
        // Define a minimum number of possible values to determine if they may be categorical
        let minOccurence = 2
        let maxOccurence = 15
        for feature in self.getHeader(){
            let values = self.getPossibleValues(key: feature.getIndex())
            if values.count >= minOccurence && values.count <= maxOccurence {
                self.getHeader()[feature.getIndex()].setDType(dType: .nominal)
                
                var listValues = [Int]()
                for item in values {
                    listValues.append(item.key as! Int)
                }
                // Seto para nominal
                 self.getHeader()[feature.getIndex()].setPossibleValues(values: listValues)
                
            }
        }
    }
    
    public func rowAtIndex(index : Int) -> [Any] {
        var instance : [Any] = []
        for key in self.data.keys.sorted() {
            instance.append(data[key]![index])
        }
        return instance
    }
    
    public func showDf() -> [Int: [Any]] {
        return self.data
    }
    
}


