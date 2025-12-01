import json

# Archivo de entrada con todos los caracteres y strokes
input_file = "C:\\Users\\ignac\\OneDrive\\Desktop\\AgilFlutter\\chinese_app\\chinese_train\\hanzi_write_master\\assets\\hanzi\\graphics.txt"
output_file = "C:\\Users\\ignac\\OneDrive\\Desktop\\AgilFlutter\\chinese_app\\chinese_train\\hanzi_write_master\\assets\\hanzi\\medians_graphics.json"

# Lista de caracteres individuales de las lecciones
lesson_chars = list('點唱歌分見面從中午得銀行時候後天大安下次沒問題對了有空再見在午餐剛下課下午半比賽結束最近忙每天書法課開始字寫可以問等一下有事有意思坐火車跟玩怎麼慢鐘頭比較快車票非常但是又舒服站或是臺南高鐵網路上便利商店同學參觀古代騎機車載捷運比故宮博物院中國公共汽車不行計程車差不多')

# Leer el JSON
with open(input_file, 'r', encoding='utf-8') as f:
    data = [json.loads(line) for line in f]

# Extraer solo medians de los caracteres de las lecciones
medians_data = []
for entry in data:
    if entry["character"] in lesson_chars and "medians" in entry:
        medians_data.append({
            "character": entry["character"],
            "medians": entry["medians"]
        })

# Guardar resultado
with open(output_file, 'w', encoding='utf-8') as f:
    for item in medians_data:
        json.dump(item, f, ensure_ascii=False)
        f.write('\n')

print(f"Archivo con medians generado en: {output_file}")
