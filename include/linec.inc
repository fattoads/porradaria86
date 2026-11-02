; HEADER: linec.inc
; DESCRIÇÃO: Declarações extern das funções e constantes de desenho fornecidas
; AUTORIA: Enrico Polez, Felipe Bruno, Vitor Tomé
; ==============================================================================

%ifndef LINEC_INC
%define LINEC_INC

; linec.asm precisa incluir esse arquivo para inicializar a variável cor com uma cor padrão (branco),
; mas incluir os símbolos extern causa conflito na compilação por causa de dupla definição. logo,
; precisamos de uma diretiva condicional pra excluir esses símbolos quando o include for chamado por linec.asm.
%ifndef LINEC_ASM

; Funções exportadas de linec.asm
extern cursor     
extern caracter   
extern plot_xy    
extern circle     
extern full_circle
extern line       

; Variáveis exportadas de linec.asm
extern cor

%endif

; ------------------------------------------------------------------------------
; Definições de cores
; ------------------------------------------------------------------------------
							; I R G B COR
preto			equ		0	; 0 0 0 0 preto
azul			equ		1	; 0 0 0 1 azul
verde			equ		2	; 0 0 1 0 verde
cyan			equ		3	; 0 0 1 1 cyan
vermelho		equ		4	; 0 1 0 0 vermelho
magenta			equ		5	; 0 1 0 1 magenta
marrom			equ		6	; 0 1 1 0 marrom
branco			equ		7	; 0 1 1 1 branco
cinza			equ		8	; 1 0 0 0 cinza
azul_claro		equ		9	; 1 0 0 1 azul claro
verde_claro		equ		10	; 1 0 1 0 verde claro
cyan_claro		equ		11	; 1 0 1 1 cyan claro
rosa			equ		12	; 1 1 0 0 rosa
magenta_claro	equ		13	; 1 1 0 1 magenta claro
amarelo			equ		14	; 1 1 1 0 amarelo
branco_intenso	equ		15	; 1 1 1 1 branco INTenso

%endif