# lang_table

lang_table is a dart plugin to generate string files from a source. Use
a table to manage all multi-language resources. Inspired by [fetch-mobile-localization-from-airtable](https://github.com/will-tsang/fetch-mobile-localization-from-airtable)


## Installation

Add this library into pubspec.yaml

``` 
dev_dependencies: 
    lang_table: 0.2.0
```
## Usage

Run the following command at root directory.Then will generate several
output files based on the source platform

```
pub run lang_table:generate
```

A below table shown all supported arguments:

| Argument  | Description |
|-----|-----|
| --platform | (Required) The platform stores all localization strings. Suppoted platforms: `airTable` |
| --input   | (Required) The source of the strings |
| --target  | (Required) Code generator for a target plaformat. Supported target: `Flutter` |
| --output-dir |  (Optional) An output folder stores all generated json files (defaults to "res/string") | 
| --api-key | (Optional) Usage of platform specific |

## Example

| Key `[code=key]`  | English `[code=en]` | Traditional Chinese `[code=zh_TW]` | Japanese `[code=ja]` |
|-----|-----|-----|-----|
| locale | English | 中文 | 日文  |
| simpleMessage  | This is a simple Message | 這是簡單消息 | これは簡単なメッセージです  |
| messageWithParams    |  Hi ${yourName}, Welcome you!   |  你好 ${yourName}，歡迎你。   |  こんにちは${yourName}、ようこそ。   |
| group.hello    |  Welcome you!   |  歡迎你。   |  ようこそ。   |

[Example Template on AirTable](https://airtable.com/shrJfZ4HlC9cjdVkk/tbl18JnO2rIR07ITN/viwzo7m3yHY73c9kp?blocks=hide)

Running the following command,

```
pub run lang_table:generate --platform=airTable --input=https://api.airtable.com/v0/appZmh0WMg3y6APAg/example --api-key={YOUR API KEY} --target=Flutter
```
Generated files like this,

```
|--- lib 
|--- res 
    |--- string 
         |--- string_en.json 
         |--- string_zh_TW.json 
         |--- string_ja.json 
```

## Meta Code 
It is required to insert into table headers for identifying the usage of
a table's column.

### Type of Meta Code

| `[code=key]`  | Used to identify the column storing a key for a message |
|-----|-----|
| `[code={Locale}]` | Used to identify the column storing a message for a specific language |

### Grouping Key
For the key in `[code=key]`, lang_table support group key. Using `'.'` to separate different groups

eg.
```
{
    "group.hello": "Welcome you!" 
}
```

## Supported Platforms

### AirTable

Example
```
pub run lang_table:generate --platform=airTable --input=https://api.airtable.com/v0/appZmh0WMg3y6APAg/example --api-key={YOUR API KEY} --target=Flutter
```

# Powered By 
- [Plaker Lab 創玩坊](https://plakerlab.com/)
- [Wenjetso 搵著數](https://www.wenjetso.com/zh_HK/)

