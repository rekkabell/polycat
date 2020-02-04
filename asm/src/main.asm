InitPosition:
  LDA #$98
  STA pos_x
  STA pos_y

  JSR LoadBackground
  JSR LoadPalettes
  JSR LoadAttributes

CreateCursor:
  LDA #$98
  STA $0200        ; set tile.y pos
  LDA #$10
  STA $0201        ; set tile.id
  LDA #$00
  STA $0202        ; set tile.attribute
  LDA #$98
  STA $0203        ; set tile.x pos

LoadSprites:
  LDX #$00              ; start at 0
LoadSpritesLoop:
  LDA sprites, x        ; load data from address (sprites + x)
  STA $0204, x          ; store into RAM address ($0200 + x)
  INX                   ; X = X + 1
  CPX #$18              ; Compare X to hex $10, decimal 16
  BNE LoadSpritesLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero

EnableSprites:
  LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000
  LDA #%00011110   ; enable sprites, enable background, no clipping on left side
  STA $2001
  
  LDA #$00         ; No background scrolling
  STA $2006
  STA $2006
  STA $2005
  STA $2005

Forever:
  JMP Forever     ;jump back to Forever, infinite loop

LoadBackground:
  LDA $2002
  LDA #$20
  STA $2006
  LDA #$00
  STA $2006

  LDA #<background ; Loading the #LOW(var) byte in asm6
  STA pointerBackgroundLowByte
  LDA #>background ; Loading the #HIGH(var) byte in asm6
  STA pointerBackgroundHighByte

  LDX #$00
  LDY #$00
LoadBackgroundLoop:
  LDA (pointerBackgroundLowByte), y
  STA $2007
  INY
  CPY #$00
  BNE LoadBackgroundLoop
  INC pointerBackgroundHighByte
  INX
  CPX #$04
  BNE LoadBackgroundLoop
  RTS

LoadPalettes:
  LDA $2002
  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006

  LDX #$00
LoadPalettesLoop:
  LDA palettes, x
  STA $2007
  INX
  CPX #$20
  BNE LoadPalettesLoop
  RTS

LoadAttributes:
  LDA $2002
  LDA #$23
  STA $2006
  LDA #$C0
  STA $2006
  LDX #$00
LoadAttributesLoop:
  LDA attributes, x
  STA $2007
  INX
  CPX #$40
  BNE LoadAttributesLoop
  RTS

NMI:
  LDA #$00
  STA $2003       ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014       ; set the high byte (02) of the RAM address, start the transfer

LatchController:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016       ; tell both the controllers to latch buttons

ReadA: 
  LDA $4016
  AND #%00000001  ; only look at bit 0
  BEQ ReadADone
  LDA #$06        ; sprite tile
  STA $0201
ReadADone:        ; handling this button is done
  
ReadB: 
  LDA $4016
  AND #%00000001  ; only look at bit 0
  BEQ ReadBDone
  LDA #$06        ; sprite tile
  STA $0201
ReadBDone:        ; handling this button is done

ReadSel: 
  LDA $4016
  AND #%00000001  ; only look at bit 0
  BEQ ReadSelDone 
  LDA #$06        ; sprite tile
  STA $0201
ReadSelDone:        ; handling this button is done

ReadStart: 
  LDA $4016
  AND #%00000001  ; only look at bit 0
  BEQ ReadStartDone 
  LDA #$06        ; sprite tile
  STA $0201
ReadStartDone:        ; handling this button is done

ReadUp: 
  LDA $4016
  AND #%00000001  ; only look at bit 0
  BEQ ReadUpDone 
  DEC pos_y
  DEC pos_y
  JSR Update
ReadUpDone:        ; handling this button is done

ReadDown: 
  LDA $4016
  AND #%00000001  ; only look at bit 0
  BEQ ReadDownDone  
  INC pos_y
  INC pos_y
  JSR Update
ReadDownDone:        ; handling this button is done

ReadLeft: 
  LDA $4016
  AND #%00000001  ; only look at bit 0
  BEQ ReadLeftDone 
  DEC pos_x
  DEC pos_x
  JSR Update
ReadLeftDone:        ; handling this button is done

ReadRight: 
  LDA $4016
  AND #%00000001  ; only look at bit 0
  BEQ ReadRightDone 
  INC pos_x
  INC pos_x
  JSR Update
ReadRightDone:        ; handling this button is done
  
  RTI             ; return from interrupt

Update:
UpdateCursor:
  LDA pos_x
  STA sprite_x
  LDA pos_y
  STA sprite_y
TestPos:
  LDA #$00
  STA is_right
  STA is_down
  JSR TestX
  JSR TestY
UpdatePolycat:
  LDA is_right
  CMP #$01
  BNE IsLookingLeft
IsLookingRight:
  LDA is_down
  CMP #$01
  BNE IsLookingRightUp
IsLookingRightDown:
  LDA #$06
  STA $020d
  LDA #$07
  STA $0211
  RTS
IsLookingRightUp:
  LDA #$0e
  STA $020d
  LDA #$0f
  STA $0211
  RTS
IsLookingLeft:
  LDA is_down
  CMP #$01
  BNE IsLookingLeftUp
IsLookingLeftDown:
  LDA #$04
  STA $020d
  LDA #$05
  STA $0211
  RTS
IsLookingLeftUp:
  LDA #$0c
  STA $020d
  LDA #$0d
  STA $0211
  RTS
UpdateDone:  
  RTS

TestX:
  LDA pos_x
  CMP #$88
  BCC TestXDone
  LDA #$01
  STA is_right
  RTS
TestXDone:
  RTS

TestY:
  LDA pos_y
  CMP #$88
  BCC TestYDone
  LDA #$01
  STA is_down
  RTS
TestYDone:
  RTS