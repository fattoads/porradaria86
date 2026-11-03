# Ferramentas
ASM      = nasm
ASMFLAGS = -f obj -g -Iinclude/
LD       = ./ALINK.EXE	#Para linux descomentar a parte wine

# Nome do Executável Final
TARGET   = jogo.exe

# Diretórios
SRC_DIR  = src
INC_DIR  = include
BUILD_DIR = build

# Lista de Objetos Necessários para o Linker
OBJS     = $(BUILD_DIR)/main.obj \
           $(BUILD_DIR)/video.obj \
           $(BUILD_DIR)/linec.obj \
           $(BUILD_DIR)/kbd.obj \
           $(BUILD_DIR)/timer.obj \
           $(BUILD_DIR)/ui.obj \
           $(BUILD_DIR)/player.obj \
           $(BUILD_DIR)/physics.obj \
           $(BUILD_DIR)/game.obj

# Alvo Padrão
all: setup $(TARGET)

# Alvo de Criação do Executável Final
$(TARGET): $(OBJS)
	$(LD) -o $(TARGET) $(OBJS)
	@echo "--------------------------------------------------------"
	@echo " Compilacao concluida com sucesso: $(TARGET)"
	@echo " Executar no DOSBox: $(TARGET)"
	@echo "--------------------------------------------------------"

# Regra Genérica para Compilar Qualquer .asm em .obj no diretório build/
$(BUILD_DIR)/%.obj: $(SRC_DIR)/%.asm
	$(ASM) $(ASMFLAGS) $< -o $@

# Criação da pasta de build se não existir
setup:
	@mkdir -p $(BUILD_DIR)

# Limpeza dos arquivos compilados
clean:
	rm -rf $(BUILD_DIR) $(TARGET)

.PHONY: all setup clean
