{
  "optionsFile": "options.json",
  "options": [],
  "exportToGame": true,
  "supportedTargets": 113497714299118,
  "extensionVersion": "1.0.0",
  "packageId": "",
  "productId": "",
  "author": "",
  "date": "2019-12-12T01:34:29",
  "license": "Proprietary",
  "description": "",
  "helpfile": "",
  "iosProps": true,
  "tvosProps": false,
  "androidProps": true,
  "installdir": "",
  "files": [
    {"filename":"GmxGenTest.dll","origname":"extensions\\GmxGenTest.dll","init":"","final":"","kind":1,"uncompress":false,"functions":[
        {"externalName":"ggt_cpp_reset_number","kind":11,"help":"","hidden":true,"returnType":2,"argCount":0,"args":[],"resourceVersion":"1.0","name":"ggt_cpp_reset_number","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"ggt_cpp_set_number","kind":1,"help":"ggt_cpp_set_number(v)","hidden":false,"returnType":2,"argCount":1,"args":[
            2,
          ],"resourceVersion":"1.0","name":"ggt_cpp_set_number","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"ggt_cpp_get_number","kind":1,"help":"ggt_cpp_get_number()->int","hidden":false,"returnType":2,"argCount":0,"args":[],"resourceVersion":"1.0","name":"ggt_cpp_get_number","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"ggt_cpp_add_numbers","kind":1,"help":"ggt_cpp_add_numbers(a, b)","hidden":false,"returnType":2,"argCount":2,"args":[
            2,
            2,
          ],"resourceVersion":"1.0","name":"ggt_cpp_add_numbers","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"ggt_cpp_add_strings","kind":1,"help":"ggt_cpp_add_strings(a, b)","hidden":false,"returnType":1,"argCount":2,"args":[
            1,
            1,
          ],"resourceVersion":"1.0","name":"ggt_cpp_add_strings","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"ggt_cpp_add_mixed","kind":1,"help":"ggt_cpp_add_mixed(a, b)","hidden":false,"returnType":1,"argCount":2,"args":[
            1,
            2,
          ],"resourceVersion":"1.0","name":"ggt_cpp_add_mixed","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"ggt_cpp_fill_bytes","kind":1,"help":"ggt_cpp_fill_bytes(buf)","hidden":false,"returnType":2,"argCount":1,"args":[
            1,
          ],"resourceVersion":"1.0","name":"ggt_cpp_fill_bytes","tags":[],"resourceType":"GMExtensionFunction",},
      ],"constants":[
        {"value":"ggt_cpp_get_number()","hidden":false,"resourceVersion":"1.0","name":"ggt_cpp_number","tags":[],"resourceType":"GMExtensionConstant",},
        {"value":"0","hidden":false,"resourceVersion":"1.0","name":"ggt_cpp_number_zero","tags":[],"resourceType":"GMExtensionConstant",},
        {"value":"1","hidden":false,"resourceVersion":"1.0","name":"ggt_cpp_number_one","tags":[],"resourceType":"GMExtensionConstant",},
        {"value":"2","hidden":false,"resourceVersion":"1.0","name":"ggt_cpp_number_two","tags":[],"resourceType":"GMExtensionConstant",},
        {"value":"3","hidden":false,"resourceVersion":"1.0","name":"ggt_cpp_number_three","tags":[],"resourceType":"GMExtensionConstant",},
        {"value":"4","hidden":false,"resourceVersion":"1.0","name":"ggt_cpp_number_four","tags":[],"resourceType":"GMExtensionConstant",},
        {"value":"5","hidden":false,"resourceVersion":"1.0","name":"ggt_cpp_number_five","tags":[],"resourceType":"GMExtensionConstant",},
      ],"ProxyFiles":[
        {"TargetMask":6,"resourceVersion":"1.0","name":"GmxGenTest_x64.dll","tags":[],"resourceType":"GMProxyFile",},
      ],"copyToTargets":9223372036854775807,"order":[
        {"name":"ggt_cpp_reset_number","path":"extensions/GmxGenTest/GmxGenTest.yy",},
        {"name":"ggt_cpp_set_number","path":"extensions/GmxGenTest/GmxGenTest.yy",},
        {"name":"ggt_cpp_get_number","path":"extensions/GmxGenTest/GmxGenTest.yy",},
        {"name":"ggt_cpp_add_numbers","path":"extensions/GmxGenTest/GmxGenTest.yy",},
        {"name":"ggt_cpp_add_strings","path":"extensions/GmxGenTest/GmxGenTest.yy",},
        {"name":"ggt_cpp_add_mixed","path":"extensions/GmxGenTest/GmxGenTest.yy",},
        {"name":"ggt_cpp_fill_bytes","path":"extensions/GmxGenTest/GmxGenTest.yy",},
      ],"resourceVersion":"1.0","name":"","tags":[],"resourceType":"GMExtensionFile",},
    {"filename":"GmxGenTest-cs.dll","origname":"extensions\\GmxGenTest-cs.dll","init":"","final":"","kind":1,"uncompress":false,"functions":[
        {"externalName":"ggt_cs_add_numbers","kind":1,"help":"ggt_cs_add_numbers(a, b)","hidden":false,"returnType":2,"argCount":2,"args":[
            2,
            2,
          ],"resourceVersion":"1.0","name":"ggt_cs_add_numbers","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"ggt_cs_add_strings","kind":1,"help":"ggt_cs_add_strings(a, b)","hidden":false,"returnType":1,"argCount":2,"args":[
            1,
            1,
          ],"resourceVersion":"1.0","name":"ggt_cs_add_strings","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"ggt_cs_fill_bytes","kind":1,"help":"ggt_cs_fill_bytes(buf)","hidden":false,"returnType":2,"argCount":1,"args":[
            1,
          ],"resourceVersion":"1.0","name":"ggt_cs_fill_bytes","tags":[],"resourceType":"GMExtensionFunction",},
      ],"constants":[],"ProxyFiles":[
        {"TargetMask":6,"resourceVersion":"1.0","name":"GmxGenTest-cs_x64.dll","tags":[],"resourceType":"GMProxyFile",},
      ],"copyToTargets":9223372036854775807,"order":[
        {"name":"ggt_cs_add_numbers","path":"extensions/GmxGenTest/GmxGenTest.yy",},
        {"name":"ggt_cs_add_strings","path":"extensions/GmxGenTest/GmxGenTest.yy",},
        {"name":"ggt_cs_fill_bytes","path":"extensions/GmxGenTest/GmxGenTest.yy",},
      ],"resourceVersion":"1.0","name":"","tags":[],"resourceType":"GMExtensionFile",},
    {"filename":"GmxGenTest.gml","origname":"extensions\\GmxGenTest.gml","init":"","final":"","kind":2,"uncompress":false,"functions":[
        {"externalName":"ggt_gml_hidden","kind":11,"help":"","hidden":true,"returnType":2,"argCount":0,"args":[],"resourceVersion":"1.0","name":"ggt_gml_hidden","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"ggt_gml_add","kind":2,"help":"ggt_gml_add(a, b)","hidden":false,"returnType":2,"argCount":2,"args":[
            2,
            2,
          ],"resourceVersion":"1.0","name":"ggt_gml_add","tags":[],"resourceType":"GMExtensionFunction",},
      ],"constants":[
        {"value":"0","hidden":false,"resourceVersion":"1.0","name":"ggt_gml_zero","tags":[],"resourceType":"GMExtensionConstant",},
      ],"ProxyFiles":[],"copyToTargets":9223372036854775807,"order":[
        {"name":"ggt_gml_hidden","path":"extensions/GmxGenTest/GmxGenTest.yy",},
        {"name":"ggt_gml_add","path":"extensions/GmxGenTest/GmxGenTest.yy",},
      ],"resourceVersion":"1.0","name":"","tags":[],"resourceType":"GMExtensionFile",},
    {"filename":"GmxGenTest.js","origname":"extensions\\GmxGenTest.js","init":"","final":"","kind":5,"uncompress":false,"functions":[
        {"externalName":"ggt_js_add","kind":5,"help":"ggt_js_add(a, b)","hidden":false,"returnType":2,"argCount":2,"args":[
            2,
            2,
          ],"resourceVersion":"1.0","name":"ggt_js_add","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"ggt_js_add_2","kind":5,"help":"ggt_js_add_2(a, b)","hidden":false,"returnType":2,"argCount":2,"args":[
            2,
            2,
          ],"resourceVersion":"1.0","name":"ggt_js_add_2","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"ggt_js_hidden_add","kind":11,"help":"","hidden":true,"returnType":2,"argCount":2,"args":[
            2,
            2,
          ],"resourceVersion":"1.0","name":"ggt_js_hidden_add","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"ggt_js_add_many","kind":5,"help":"ggt_js_add_many(value, ...values)","hidden":false,"returnType":2,"argCount":-1,"args":[],"resourceVersion":"1.0","name":"ggt_js_add_many","tags":[],"resourceType":"GMExtensionFunction",},
      ],"constants":[],"ProxyFiles":[],"copyToTargets":9223372036854775807,"order":[
        {"name":"ggt_js_add","path":"extensions/GmxGenTest/GmxGenTest.yy",},
        {"name":"ggt_js_add_2","path":"extensions/GmxGenTest/GmxGenTest.yy",},
        {"name":"ggt_js_hidden_add","path":"extensions/GmxGenTest/GmxGenTest.yy",},
        {"name":"ggt_js_add_many","path":"extensions/GmxGenTest/GmxGenTest.yy",},
      ],"resourceVersion":"1.0","name":"","tags":[],"resourceType":"GMExtensionFile",},
  ],
  "classname": "",
  "tvosclassname": "",
  "tvosdelegatename": "",
  "iosdelegatename": "",
  "androidclassname": "",
  "sourcedir": "",
  "androidsourcedir": "",
  "macsourcedir": "",
  "maccompilerflags": "",
  "tvosmaccompilerflags": "",
  "maclinkerflags": "",
  "tvosmaclinkerflags": "",
  "androidcodeinjection": "",
  "ioscodeinjection": "",
  "tvoscodeinjection": "",
  "iosSystemFrameworkEntries": [],
  "tvosSystemFrameworkEntries": [],
  "iosThirdPartyFrameworkEntries": [],
  "tvosThirdPartyFrameworkEntries": [],
  "IncludedResources": [],
  "androidPermissions": [],
  "copyToTargets": 113497714299118,
  "parent": {
    "name": "Extensions",
    "path": "folders/Extensions.yy",
  },
  "resourceVersion": "1.2",
  "name": "GmxGenTest",
  "tags": [],
  "resourceType": "GMExtension",
}