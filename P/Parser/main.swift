//
//  main.swift
//  Parser
//
//  Created by Емельянов Константин Станиславович on 19.12.2023.
//

import MachOKit

let args = CommandLine.arguments
let needed = args.dropFirst(args.count - 2)
print(needed)
guard needed.count == 2 else { exit(1) }
let fm = FileManager.default
var metaData: ([String: Set<String>], [String: Set<String>]) = ([:], [:])
let metaList = ["cstring"]

func createMeta(for path: String) -> [String: Set<String>] {
	let url = URL(fileURLWithPath: path)
	let macho: MKMachOImage?
	do {
		let document = try Document(contentsOf: url, ofType: ".exec")
		macho = document.rootNode.macho
	} catch {
		print("Ne vishlo")
		exit(1)
	}
	guard let macho else {
		print("Ne vishlo")
		exit(1)
	}
	let sections = macho.sections
//	let commands = macho.loadCommands
	var result: [String: Set<String>] = [:]

	metaList.forEach { key in
		var data: Set<String> = []
		for (_, section) in sections {
			switch section.type {
			case .cStringLiterals:
				if let cstrings = section as? MKCStringSection {
					cstrings.strings.forEach { data.insert($0.string ?? "") }
				}
			default: continue
//				print(section.type, section.name)
			}
		}
		result[key] = data
	}
	return result
}

func compare(lhs: Set<String>, rhs: Set<String>) -> Double {
	lhs.intersection(rhs).count
	
	return Double(lhs.intersection(rhs).count) / Double([lhs.count, rhs.count].max()!)
}

for (index, path) in args.enumerated() {
	var isDir: ObjCBool = false
	guard fm.fileExists(atPath: path, isDirectory: &isDir) else {
		print("Директория \(path) не найдена")
		exit(1)
	}
	let meta = createMeta(for: path)
	if index == 0 {
		metaData = (meta, metaData.1)
	} else {
		metaData = (metaData.0, meta)
	}
}

print(metaData.0)

for key in metaList {
	guard let lhs = metaData.0[key],
		  let rhs = metaData.1[key] else {
		print("metadata in section \(key) missing")
		continue
	}
	let equality = compare(lhs: lhs, rhs: rhs)
	print("for \(key) similarity equal \(equality)")
}
