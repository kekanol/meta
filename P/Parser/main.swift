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
var metaData: (Set<String>, Set<String>) = ([], [])

func createMeta(for path: String) -> Set<String> {
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
	let loadCommands = macho.loadCommands
	var result: Set<String> = []

	for dylib in loadCommands where dylib.cmd == 12 { // 12 - значение LC_LOAD_DYLIB
		if let loadDylib = dylib as? MKLCLoadDylib {
			result.insert(loadDylib.name.description)
		}
	}
	return result
}

func compare(lhs: Set<String>, rhs: Set<String>) -> Double {
	return Double(lhs.intersection(rhs).count) / Double([lhs.count, rhs.count].max()!)
}

for (index, path) in needed.enumerated() {
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

let equality = ((compare(lhs: metaData.0, rhs: metaData.1) * 100) * 100).rounded() / 100
print("similarity equal \(equality) %")
