//
//  main.swift
//  Parser
//
//  Created by Емельянов Константин Станиславович on 19.12.2023.
//

import MachOKit

let args = CommandLine.arguments
let needed = args.dropFirst(args.count - 2)
guard needed.count == 2 else { exit(1) }
let fm = FileManager.default
var metaData: ([String: Set<String>], [String: Set<String>]) = ([:], [:])
var sizes: ([String: String], [String: String]) = ([:], [:])
var metaList: Set<String> = []

func createMeta(for path: String) -> ([String: Set<String>], [String: String]) {
	let url = URL(fileURLWithPath: path)
	let macho: MKMachOImage?
	do {
		let document = try Document(contentsOf: url, ofType: "")
		macho = document.rootNode.macho
	} catch {
		print("Pizda")
		exit(1)
	}
	guard let macho else {
		print("Ne vishlo")
		exit(1)
	}
	let sections = macho.sections
	let loadCommands = macho.loadCommands
	sections.forEach { metaList.insert($0.value.name ?? "") }
	var result: [String: Set<String>] = [:]
	var sizes: [String: String] = [:]
	metaList.forEach { key in
		guard let section = sections.first(where: { $0.value.name == key })?.value else { return }
		var data: Set<String> = []
		if let cstrings = section as? MKCStringSection {
			cstrings.strings.forEach { data.insert($0.string ?? "") }
			result[key] = data
		} else if let datas = section as? MKDataSection {
			sizes[key] =  "\(datas.size)"
		} else if let pointers = section as? MKPointerListSection<AnyObject> {
			sizes[key] =  "\(pointers.size)"
		} else if let image = section as? MKObjCImageInfoSection {
			sizes[key] = "\(image.size)"
		}
	}

	var dylibs: Set<String> = []
	var cmdSizes: Set<String> = []
	for cmd in loadCommands {
		if cmd.cmd == 12, // 12 - значение LC_LOAD_DYLIB
		   let loadDylib = cmd as? MKLCLoadDylib {
			dylibs.insert(loadDylib.name.description)
		}
		cmdSizes.insert("\(cmd.cmdSize)")
	}
	metaList.insert("dylib")
	metaList.insert("cmdSizes")
	result["dylib"] = dylibs
	result["cmdSizes"] = cmdSizes
	return (result, sizes)
}

func compare(lhs: Set<String>, rhs: Set<String>) -> Double {
	if lhs.count == 1, let L = Double(lhs.first!), rhs.count == 1, let R = Double(rhs.first!) {
		return [L, R].min()! / [L, R].max()!
	}

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
		metaData = (meta.0, metaData.1)
		sizes = (meta.1, sizes.1)
	} else {
		metaData = (metaData.0, meta.0)
		sizes = (sizes.0, meta.1)
	}
}

for key in ["__objc_catlist",
			"__objc_classrefs",
			"__objc_const",
			"__objc_data",
			"__objc_nlclslist",
			"__objc_protolist",
			"__objc_protorefs",
			"__objc_selrefs",
			"__objc_superrefs"] {
	guard let lhs = sizes.0[key],
		  let rhs = sizes.1[key] else {
		print("no data for \(key)")
		continue
	}
	let equality = ((compare(lhs: [lhs], rhs: [rhs]) * 100) * 100).rounded() / 100
	print("\(key) metadata size similarity equal \(equality) %")
}

for key in metaList.sorted() {
	if ["__objc_catlist",
		"__objc_classrefs",
		"__objc_const",
		"__objc_data",
		"__objc_nlclslist",
		"__objc_protolist",
		"__objc_protorefs",
		"__objc_selrefs",
		"__objc_superrefs"].contains(key) {
		continue
	}
	if let lhs = metaData.0[key],
		  let rhs = metaData.1[key] {
		let equality = ((compare(lhs: lhs, rhs: rhs) * 100) * 100).rounded() / 100
		if equality.isNaN { continue }
		print("\(key) similarity equal \(equality) %, metadata count = \([lhs.count, rhs.count].max()!)")
	}
}


