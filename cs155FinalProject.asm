;*****************************************************************************
; Author: William Wotherspoon
; Date: 05/13/2025
; Revision: 1.0
;
; Description:
;   a text based adventure game that also uses ascii animations for pizazz
;
; Register Usage:
; R0 - used for traps
; R1 - not used
; R2 - holds the address for user choice 2
; R3 - holds the address for user choice 3
; R4 - not used
; R5 - not used
; R6 - not used
; R7 - not used
;****************************************************************************/
.ORIG x3000
    AND R0, R0, #0
    ST R0, BOOL ;if 1 run loop for winner machine amount else normal loop amount(12)
    
;load and display introductory text
    LD R0, *PrmptA
    PUTS

 JSR dispArcade ; display the arcade if user picked option 2
 JSR wait
    LD R0, *QuestA ;display first option questions
    PUTS
    LD R2, *QstARep2
    LD R3, *QstARep3 ; load the response options into R3 and R2
    JSR getChoice
    LD R0, *QstARep1 ; default response
    PUTS
JSR wait

    LD R0, *QuestB ;display second option questions
    PUTS
    LD R2, *QstBRep2
    LD R3, *QstBRep3 
    JSR getChoice
    NOT R0, R0
    ADD R0, R0, #1 ; get the negative value of user choice and check if user pick option 2
    ADD R0, R2, R0
    BRnp storyContinue
    LD R0, *theRiddle ;load and display riddle text
    PUTS
    JSR riddlePath ; execute function for user answering the riddle
    ADD R1, R1, #0
    BRp skipARC ; if riddle correct continue 
    ADD R1, R1, #0
    BRz AltENDING ; riddle incorrect run different ending
    
skipARC
    LD R0, *riddleWin
    PUTS
    JSR wait
storyContinue
    LD R0, *QstBRep1
    PUTS
JSR wait

    LD R0, *QuestC ;display third option questions
    PUTS
    LD R2, *QstCRep2
    LD R3, *QstCRep3
    JSR getChoice
    JSR wait
    JSR genOutcome ; calculate 1-3 based off user input
    JSR finale ; depending on luckSEED run the slot machines
    BR normalENDING
AltENDING
    LD R0, *riddleLose
    PUTS
normalENDING
    ;ending screen display
    LD R0, *creditspt1 
    PUTS
    LD R0, *creditspt2
    PUTS   
HALT


*waitdisp       .FILL waitdisp
*PrmptA         .FILL PrmptA
*QuestA         .FILL QuestA
*QstARep1       .FILL QstARep1
*QstARep2       .FILL QstARep2
*QstARep3       .FILL QstARep3
*QuestB         .FILL QuestB
*QstBRep1       .FILL QstBRep1
*QstBRep2       .FILL QstBRep2
*QstBRep3       .FILL QstBRep3
*QuestC         .FILL QuestC
*QstCRep2       .FILL QstCRep2
*QstCRep3       .FILL QstCRep3
*theRiddle      .FILL theRiddle
*riddleLose     .FILL riddleLose
*riddleWin      .FILL riddleWin
*arcade1        .FILL arcade1 
*arcade2        .FILL arcade2 
*sltM1Pt1Str    .FILL sltM1Pt1Str
*sltM1Pt2Str    .FILL sltM1Pt2Str
*sltM2Pt1Str    .FILL sltM2Pt1Str
*sltM2Pt2Str    .FILL sltM2Pt2Str
*sltM3Pt1Str    .FILL sltM3Pt1Str
*sltM3Pt2Str    .FILL sltM3Pt2Str
*sltM4Pt1Str    .FILL sltM4Pt1Str
*sltM4Pt2Str    .FILL sltM4Pt2Str
*creditspt1     .FILL creditspt1
*creditspt2     .FILL creditspt2

neg49 .FILL #-49
neg50 .FILL #-50
neg51 .FILL #-51
BOOL .BLKW #1
luckSEED .BLKW #1


;************************getChoice*****************************
; Description: lets the user choice 1, 2 or 3 then displays the response that corresponds with the choice
;   
;
; Register Usage:
; R0 - used for trap then holds the user choice value
; R1 - used for calcs
; R2 - holds address for prompt if user enters 2
; R3 - holds address for prompt if user enters 2
; R4 - used to load the random val and the vals used to check user input
; R5 - not used
; R6 - not used
;R7 - return address from subroutine
;**************************************************************
getChoice
ST R7, save0R7
verifyLOOP
    IN
    LD R4, luckSEED
    ADD R4, R4, R0 ; add user choice to the luck value for later use
    ST R4, luckSEED
    AND R1, R1, #0
    LD R4, neg49
    ADD R1, R0, R4 ;check if userval==49 and return if true
    BRz DONE
    
    AND R1, R1, #0
    LD R4, neg50
    ;check if userval==50 and print response and return
    ADD R1, R0, R4 
    BRnp NEXT
    ADD R0, R2, #0
    PUTS
    BR DONE

NEXT
    AND R1, R1, #0
    LD R4, neg51
    ;check if uservall is == 51 and print response and return
    ADD R1, R0, R4 
    BRnp verifyLOOP
    ADD R0, R3, #0
    PUTS

DONE
LD R7, save0R7
RET
save0R7 .BLKW #1


;************************riddlePath*****************************
; Description: user enters a word up to length 10 it is then checked to see if it is equal to the key word
;
; Register Usage:
; R0 - used for trap
; R1 - return value if 1 if passed the riddle 0 if failed the riddle
; R2 - used for calcs and address of keyword
; R3 - address of user word
; R4 - loop counter
; R5 - character from user word
; R6 - character from key word
; R7 - not used
;**************************************************************
riddlePath
ST R7, save1R7
    AND R4, R4, #0 
    ADD R4, R4, #10 ; set r4 to 10 used as loop counter
    LEA R3, userWord ; sarting address of where user word is stored
ridLOOP
    GETC
    OUT
    STR R0, R3, #0 ; store the character into memory
    ADD R3, R3, #1
    AND R2, R2, #0
    ADD R2, R0, #-10 ;check if user presses enter(10 is ascii for enter)
    BRz wordEntered
    ADD R4, R4, #-1 ; loop again if loop counter is positive
    BRp ridLOOP
    BR wordinputed
wordEntered
    ADD R3, R3, #-1 ; decrements address to replace the enter with null
wordinputed
    AND R0, R0, #0
    STR R0, R3, #0 ; store null at the end of the string
    
    ;go through the word and check if it is == "keyboard"
    LEA R3, userWord
    LEA R2, keyWord
    ADD R2, R2, #-1
    ADD R3, R3, #-1
    AND R4, R4, #0
checkLOOP
    ;increment userword and keyword address to compare
    ADD R2, R2, #1 
    ADD R3, R3, #1
    
    ;load value from user word into R5 and value from keyword into R6
    LDR R5, R2, #0
    LDR R6, R3, #0
    ;compare character of keyword and userword
    ADD R4, R4, #1
    NOT R5, R5
    ADD R5, R5, #1
    ADD R0, R5, R6
    BRz checkLOOP
    
    ;check how many successful loops of comparision occured if 12 the words are the same
    AND R1, R1, #0
    ADD R4, R4, #-12
    BRnp fail
    ADD R1, R1, #1
fail
    
LD R7, save1R7
RET
save1R7 .BLKW #1
userWord .BLKW #11
keyWord .STRINGZ "keyboard"
keyNULL .BLKW #2


;************************dispAracde*****************************
; Description: displays the arcade ascii art
;   
;
; Register Usage:
; R0 - used for trap and displaying the arcade
; R1 - not used
; R2 - not used
; R3 - not used
; R4 - not used
; R5 - not used
; R6 - not used
; R7 - return address from subroutine
;**************************************************************
dispArcade
ST R7, save1.5R7
;goes through each slice of the arcade and displays
    LD R0, *arcade1
    PUTS
    LD R0, *arcade2
    PUTS
LD R7, save1.5R7
RET
arcOFF .FILL #20
save1.5R7 .BLKW #1


;************************dispSlot*****************************
; Description: displays the slot machine ascii animation based off the luck SEED value
;   
;
; Register Usage:
; R0 - used for trap and checking bool
; R1 - address for current slot machine pt1
; R2 - holds the current offset for the state being displayed
; R3 - address for current slot machine pt2
; R4 - used for sleep loop
; R5 - loop counter
; R6 - not used
; R7 - return address from subroutine
;**************************************************************
dispSlot
ST R7, save2R7
    AND R2, R2, #0
    LD R0, BOOL
    LD R5, winLoopCount
    ADD R0, R0, #-1 ; check if bool is zero run winner loop amount if bool==1 else run normal loop amount
    BRz loopSLOT
    AND R5, R5, #0
    ADD R5, R5, #12

loopSLOT
    ;displays slot machine current iteration
    ADD R0, R1, R2
    PUTS
    ADD R0, R3, R2
    PUTS
  
    ;sleep loop  
    LD R4, amount
LOOP
        ADD R4, R4, #-1
    BRp LOOP
    
    ;increase offset for next iteration
    LD R0, slotOFF
    ADD R2, R2, R0
    ADD R5, R5, #-1 ; decrease loop counter
    BRp loopSLOT

LD R7, save2R7
RET
winLoopCount .FILL #17
amount .FILL #6000
slotOFF .FILL #391
save2R7 .BLKW #1


;************************genOutcome*****************************
;
; Description: generate 1-3 to choose the outcome of the story
;  
;
; Register Usage:
; R0 - not used
; R1 - not used
; R2 - not used
; R3 - not used
; R4 - not used
; R5 - not used
; R6 - not used
; R7 - not used
;R7 - return address from subroutine
;**************************************************************
genOutcome
ST R7, save3R7
    LD R2, luckSEED ; variable value based off users choices

; reduce by 3 until negative then increment by 3 once generating a value of 1-3
calcLOOP
    ADD R2, R2, #-3
BRp calcLOOP
    ADD R1, R2, #3
    ST R1, luckSEED
LD R7, save3R7
RET
save3R7 .BLKW #1


;************************wait*****************************
; Description: prompts user to press enter when ready to continue pauses program until this occurs
;
; Register Usage:
; R0 - used for trap
; R1 - not used
; R2 - not used
; R3 - not used
; R4 - not used
; R5 - not used
; R6 - not used
; R7 - not used
;R7 - return address from subroutine
;**************************************************************
wait
ST R7, save4R7
    ; pause the program until user presses a key
    LEA R0, continue
    PUTS
    GETC

LD R7, save4R7
RET
continue .STRINGZ "Press Enter to continue: "
save4R7 .BLKW #1


;************************finale*****************************
; Description:
;   
;
; Register Usage:
; R0 - used for trap and calcs
; R1 - stores part 1 of each slot machine iteration
; R2 - holds the luck value for choosing which slot machine outcome will occur(1-3)
; R3 - stores part 2 of each slot machine iteration
; R4 - not used
; R5 - not used
; R6 - not used
; R7 - not used
;**************************************************************
finale
ST R7, save5R7
    LD R2, luckSEED
    ADD R0, R2, #-1
    BRnp NEXTOPT
    LD R1, *sltM1Pt1Str
    LD R3, *sltM1Pt2Str
    BR loseSlotCycle
NEXTOPT
    ;same loop as previous option except the start point of the slot machines is for machine 2
    ADD R0, R2, #-2
    BRnp NEXTOPT2
    ;load the machines into registers
    LD R1, *sltM2Pt1Str
    LD R3, *sltM2Pt2Str
loseSlotCycle
    JSR dispSlot
    LD R0, *lose1Resp ;print first lose text
    PUTS
    JSR wait
    
    LD R1, *sltM2Pt1Str
    LD R3, *sltM2Pt2Str
    JSR dispSlot    
    LD R0, *lose2Resp ;print first second text
    PUTS
    JSR wait

    LD R1, *sltM3Pt1Str
    LD R3, *sltM3Pt2Str
    JSR dispSlot
    ;print lose screen and darkness
    LD R0, *loseResp 
    PUTS
    LD R0, *darkness
    PUTS
    BR THEEND

NEXTOPT2
    ;same loop as previous option except wins on the third slot attempt
    ADD R0, R2, #-3
    BRnp THEEND
    LD R1, *sltM1Pt1Str
    LD R3, *sltM1Pt2Str
    JSR dispSlot
    LD R0, *lose1Resp
    PUTS
    JSR wait

    LD R1, *sltM2Pt1Str
    LD R3, *sltM2Pt2Str
    JSR dispSlot    
    LD R0, *lose2Resp
    PUTS
    JSR wait
    
    LD R1, *sltM4Pt1Str
    LD R3, *sltM4Pt2Str
    LD R0, BOOL
    ADD R0, R0, #1 ; change bool to 1 so win loop amount occurs in slot machine display
    ST R0, BOOL
    JSR dispSlot
    LD R0, *winResp ; print the win screen
    PUTS
    BR THEEND
    
THEEND
JSR wait
LD R7, save5R7
RET
save5R7 .BLKW #1
*lose1Resp      .FILL lose1Resp
*lose2Resp      .FILL lose2Resp
*loseResp       .FILL loseResp
*winResp        .FILL winResp
*darkness       .FILL darkness


waitdisp    .STRINGZ "\n.                                                           "
PrmptA      .STRINGZ "\nIn a dark haze you slowly open your eyes revealing a long dark street with a small arcade perched at the end of the street. Bright neon lights mark the store's entrance inviting you to come in.\n"
QuestA      .STRINGZ "\nDO YOU WISH TO ENTER?\n1. Enter the arcade\n2. Turn around and go the opposite direction\n3. Do you think you're dreaming? If so, pinch yourself.\n"
QstARep1    .STRINGZ "\nThe door creaks as the weight of the door resists your push. Slowly opening to reveal a quaint arcade with a few old machines. In the back is a red door marked with three eyes in a horizontal row.\n"
QstARep2    .STRINGZ "You turn around in the opposite direction to find that the same arcade is at the end of the street in the opposite direction. There appears to be no other choice so you enter into the arcade.\n"
QstARep3    .STRINGZ "With a quick pinch you feel a slight nip. An unfortunate sign that this is no dream. After your failed experiment you enter into the building.\n"
QuestB      .STRINGZ "\nWHAT SHALL YOU DO?\n1. Enter through the red door\n2. Play one a of the machines\n3. Turn around and leave the arcade\n"
QstBRep1    .STRINGZ "\nThrough the red door a large jet black monster approaches you. Before you have a chance to reconsider the door through which you entered closes. The monster stops and stares pausing as if to inspect you. Suddenly in a gravelly voice the monster says \"Do you wish to play a game?\"\n"
QstBRep2    .STRINGZ "The machine is producing a low rumble and the screen is dim but has remnants of light. You look for a way to start the game but there is no means visible. After pressing a few buttons it appears these machines may have never been intended to be played.\n"
QstBRep3    .STRINGZ "As you approach the door you feel a cool breeze glide past your ankles. As soon as you unlatch the door it is flung open by a burst of wind. This door that once led to a quiet street now reveals a dark turbulent abyss one that you most definitely do not wish to enter.\n"
QuestC      .STRINGZ "\nYOU RESPOND BY SAYING\n1. I suppose I will\n2. What game would I be playing\n3. I should really be going so I must pass on your game today.\n"
QstCRep2    .STRINGZ "\"It is a rather simple game that you may have heard of but with a twist. It is slots you pull the lever the wheels will spin and if you are lucky a great reward will be yours and if you are not lucky well lets say I will be rewarded\".\n"
QstCRep3    .STRINGZ "The monster quickly responds \"Oh but I insist this is a game that you must play\" with little choice in the matter you decide to play.\n"
SlotIntr    .STRINGZ "In front of you sits an old slot machine. Rust crawls up the base and the once glistening glass is not a dull yellow. The symbols still glow although you do notice some of the symbols are not what they should be. Strange markings appear to corrupt the machine, you ponder if this monster will even let you win.\n"
lose1Resp   .STRINGZ "\"Well it appears you have two more tries\". You look into your hand and the two tokens with an eye engraved on the surface. Slowly you slot the token into the machine spurring the lights and noises.\n"
lose2Resp   .STRINGZ "With a grin slowly shaping the monster says \"One last attempt I wish you the best of luck\". You grip the token and reach for the slot pushing it into the machine. It is time for your final attempt.\n"
winResp     .STRINGZ "The monster frowns displeased with the result. Reluctantly the monster says “You have won this time but next time you won't be so lucky\". With a loud roar the monster and the machine vanish revealing a large chest full of golden chips and a door that looks awfully familiar. As you approach it you realize it is the door to your home.\n"
loseResp    .STRINGZ "The monster grins pleased with the outcome \"I see lady luck has not shown you favor\" suddenly the monster's mouth widens engulfing the room in darkness. The slot machine floats inviting you to try your luck one last time. With a pull of the lever the machine quickly snaps to three wide grins as the darkness engulfs you.\n"
darkness    .STRINGZ "##################################################################\n##################################################################\n##################################################################\n##################################################################\n##################################################################\n"
theRiddle   .STRINGZ "\nSuddenly the machine lights up. A pixelated face forms on the screen in a shape resembling a smile. As you begin to take a step back the machine says \"Going so soon? I have a riddle. Should you solve it you are free to leave, if you can not solve you must do me a favor\". \"I have keys but open no locks. I have space but no room. You can enter but not go outside. What am I?\"\nYour Answer(1 word and max length of 10): "
riddleLose  .STRINGZ "\"INCORRECT\" in an instant everything goes dark all you can see is the faint light from the outside of the arcade machine.\n"
riddleWin   .STRINGZ "Answering the riddle appears to have satisfied the machine. You continue walking backwards towards the red door.\n"
arcade1     .STRINGZ "  ________________________                                      \n /                       /|                                     \n/_______________________/ |                                     \n|    💡💡ARCADE💡💡    | |                                     \n|       _________       | |                                     \n|       |   |   |       | |                                     \n|       |   |   |       |                                       \n"
arcade2     .STRINGZ "______________________________________________________________\n--------------------------------------------------------------\n______________________________________________________________\n"
  
  
sltM1Pt1Str .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                      THE SLOTS  \n               =======================\n               [  💵  |  👀  |  😀  ]   O\n               [  🍒  |  💎  |  💵  ]   |\n"
sltM1Pt2Str .STRINGZ "               [> 😀 <|> 🍒 <|> 🍒 <]   |\n               [  👀  |  😞  |  💎  ]   |\n               [  😞  |  😀  |  😞  ]___|\n               =======================                  \n\n\n\n"
 
            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                      THE SLOTS  \n               =======================\n               [  💎  |  💵  |  👀  ]   O\n               [  💵  |  👀  |  😀  ]   |\n"
            .STRINGZ "               [> 🍒 <|> 💎 <|> 💵 <]   |\n               [  😀  |  🍒  |  🍒  ]   |\n               [  👀  |  😞  |  💎  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                      THE SLOTS  \n               =======================\n               [  😞  |  😀  |  😞  ]   O\n               [  💎  |  💵  |  👀  ]   |\n"
            .STRINGZ "               [> 💵 <|> 👀 <|> 😀 <]   |\n               [  🍒  |  💎  |  💵  ]   |\n               [  😀  |  💵  |  💵  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                      THE SLOTS  \n               =======================\n               [  👀  |  😞  |  💎  ]   O\n               [  😞  |  😀  |  😞  ]   |\n"
            .STRINGZ "               [> 💎 <|> 💵 <|> 👀 <]   |\n               [  💵  |  👀  |  😀  ]   |\n               [  🍒  |  💎  |  💵  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                      THE SLOTS  \n               =======================\n               [  😀  |  🍒  |  🍒  ]   O\n               [  👀  |  😞  |  💎  ]   |\n"
            .STRINGZ "               [> 😞 <|> 😀 <|> 😞 <]   |\n               [  💎  |  💵  |  👀  ]   |\n               [  💵  |  👀  |  😀  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                      THE SLOTS  \n               =======================\n               [  🍒  |  💎  |  💵  ]   O\n               [  😀  |  🍒  |  🍒  ]   |\n"
            .STRINGZ "               [> 👀 <|> 😞 <|> 💎 <]   |\n               [  😞  |  😀  |  😞  ]   |\n               [  💎  |  💵  |  👀  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                      THE SLOTS  \n               =======================\n               [  💵  |  👀  |  😀  ]   O\n               [  🍒  |  💎  |  💵  ]   |\n"
            .STRINGZ "               [> 😀 <|> 🍒 <|> 🍒 <]   |\n               [  👀  |  😞  |  💎  ]   |\n               [  😞  |  😀  |  😞  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                      THE SLOTS  \n               =======================\n               [  💎  |  💵  |  👀  ]   O\n               [  💵  |  👀  |  😀  ]   |\n"
            .STRINGZ "               [> 🍒 <|> 💎 <|> 💵 <]   |\n               [  😀  |  🍒  |  🍒  ]   |\n               [  👀  |  😞  |  💎  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                      THE SLOTS  \n               =======================\n               [  💎  |  😀  |  😞  ]   O\n               [  💵  |  💵  |  👀  ]   |\n"
            .STRINGZ "               [> 🍒 <|> 👀 <|> 😀 <]   |\n               [  😀  |  💎  |  💵  ]   |\n               [  👀  |  🍒  |  🍒  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                      THE SLOTS  \n               =======================\n               [  💎  |  😞  |  💎  ]   O\n               [  💵  |  😀  |  😞  ]   |\n"
            .STRINGZ "               [> 🍒 <|> 💵 <|> 👀 <]   |\n               [  😀  |  👀  |  😀  ]   |\n               [  👀  |  💎  |  💵  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                      THE SLOTS  \n               =======================\n               [  💎  |  😞  |  🍒  ]   O\n               [  💵  |  😀  |  💎  ]   |\n"
            .STRINGZ "               [> 🍒 <|> 💵 <|> 😞 <]   |\n               [  😀  |  👀  |  👀  ]   |\n               [  👀  |  💎  |  😀  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                      THE SLOTS  \n               =======================\n               [  💎  |  😞  |  💵  ]   O\n               [  💵  |  😀  |  🍒  ]   |\n"
            .STRINGZ "               [> 🍒 <|> 💵 <|> 💎 <]   |\n               [  😀  |  👀  |  😞  ]   |\n               [  👀  |  💎  |  👀  ]___|\n               =======================                  \n\n\n\n"


sltM2Pt1Str .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  🍒  |  💎  |  😞  ]   O\n               [  👀  |  💵  |  💵  ]   |\n"
sltM2Pt2Str .STRINGZ "               [> 😀 <|> 👀 <|> 🍒 <]   |\n               [  💎  |  😀  |  😀  ]   |\n               [  😞  |  🍒  |  👀  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  💵  |  😞  |  💎  ]   O\n               [  🍒  |  💎  |  😞  ]   |\n"
            .STRINGZ "               [> 👀 <|> 💵 <|> 💵 <]   |\n               [  😀  |  👀  |  🍒  ]   |\n               [  💎  |  😀  |  😀  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  😞  |  🍒  |  👀  ]   O\n               [  💵  |  😞  |  💎  ]   |\n"
            .STRINGZ "               [> 🍒 <|> 💎 <|> 😞 <]   |\n               [  👀  |  💵  |  💵  ]   |\n               [  😀  |  👀  |  🍒  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  💎  |  😀  |  😀  ]   O\n               [  😞  |  🍒  |  👀  ]   |\n"
            .STRINGZ "               [> 💵 <|> 😞 <|> 💎 <]   |\n               [  🍒  |  💎  |  😞  ]   |\n               [  👀  |  💵  |  💵  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  😀  |  👀  |  🍒  ]   O\n               [  💎  |   😀 |  😀  ]   |\n"
            .STRINGZ "               [> 😞 <|> 🍒 <|> 👀 <]   |\n               [  💵  |  😞  |  💎  ]   |\n               [  🍒  |  💎  |  😞  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  👀  |  💵  |  💵  ]   O\n               [  😀  |  👀  |  🍒  ]   |\n"
            .STRINGZ "               [> 💎 <|< 😀 <|> 😀 <]   |\n               [  😞  |  🍒  |  👀  ]   |\n               [  💵  |  😞  |  💎  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  🍒  |  💎  |  😞  ]   O\n               [  👀  |  💵  |  💵  ]   |\n"
            .STRINGZ "               [> 😀 <|> 👀 <|> 🍒 <]   |\n               [  💎  |  😀  |  😀  ]   |\n               [  😞  |  🍒  |  👀  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  💵  |  😞  |  💎  ]   O\n               [  🍒  |  💎  |  😞  ]   |\n"
            .STRINGZ "               [> 👀 <|> 💵 <|> 💵 <]   |\n               [  😀  |  👀  |  🍒  ]   |\n               [  💎  |  😀  |  😀  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  😞  |  🍒  |  👀  ]   O\n               [  💵  |  😞  |  💎  ]   |\n"
            .STRINGZ "               [> 🍒 <|> 💎 <|> 😞 <]   |\n               [  👀  |  💵  |  💵  ]   |\n               [  😀  |  👀  |  🍒  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  😞  |  😀  |  😀  ]   O\n               [  💵  |  🍒  |  👀  ]   |\n"
            .STRINGZ "               [> 🍒 <|> 😞 <|> 💎 <]   |\n               [  👀  |  💎  |  😞  ]   |\n               [  😀  |  💵  |  💵  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  😞  |  👀  |  🍒  ]   O\n               [  💵  |  😀  |  😀  ]   |\n"
            .STRINGZ "               [> 🍒 <|> 🍒 <|> 👀 <]   |\n               [  👀  |  😞  |  💎  ]   |\n               [  😀  |  💎  |  😞  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  😞  |  👀  |  💵  ]   O\n               [  💵  |  😀  |  🍒  ]   |\n"
            .STRINGZ "               [> 🍒 <|< 🍒 <|> 😀 <]   |\n               [  👀  |  😞  |  👀  ]   |\n               [  😀  |  💎  |  💎  ]___|\n               =======================                  \n\n\n\n"
     
            
sltM3Pt1Str .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  💵  |  👀  |  🍒  ]   O\n               [  😀  |  💎  |  💵  ]   |\n"
sltM3Pt2Str .STRINGZ "               [> 👀 <|> 💵 <|> 😞 <]   |\n               [  💎  |  😀  |  👀  ]   |\n               [  🍒  |  😞  |  💎  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  😞  |  🍒  |  😀  ]   O\n               [  💵  |  👀  |  🍒  ]   |\n"
            .STRINGZ "               [> 😀 <|> 💎 <|> 💵 <]   |\n               [  👀  |  💵  |  😞  ]   |\n               [  💎  |  😀  |  👀  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  🍒  |  😞  |  💎  ]   O\n               [  😞  |  🍒  |  😀  ]   |\n"
            .STRINGZ "               [> 💵 <|> 👀 <|> 🍒 <]   |\n               [  😀  |  💎  |  💵  ]   |\n               [  👀  |  💵  |  😞  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  💎  |  😀  |  👀  ]   O\n               [  🍒  |  😞  |  💎  ]   |\n"
            .STRINGZ "               [> 😞 <|> 🍒 <|> 😀 <]   |\n               [  💵  |  👀  |  🍒  ]   |\n               [  😀  |  💎  |  💵  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  👀  |  💵  |  😞  ]   O\n               [  💎  |  😀  |  👀  ]   |\n"
            .STRINGZ "               [> 🍒 <|> 😞 <|> 💎 <]   |\n               [  😞  |  🍒  |  😀  ]   |\n               [  💵  |  👀  |  🍒  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  😀  |  💎  |  💵  ]   O\n               [  👀  |  💵  |  😞  ]   |\n"
            .STRINGZ "               [> 💎 <|> 😀 <|> 👀 <]   |\n               [  🍒  |  😞  |  💎  ]   |\n               [  😞  |  🍒  |  😀  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  💵  |  👀  |  🍒  ]   O\n               [  😀  |  💎  |  💵  ]   |\n"
            .STRINGZ "               [> 👀 <|> 💵 <|> 😞 <]   |\n               [  💎  |  😀  |  👀  ]   |\n               [  🍒  |  😞  |  💎  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  😞  |  🍒  |  😀  ]   O\n               [  💵  |  👀  |  🍒  ]   |\n"
            .STRINGZ "               [> 😀 <|> 💎 <|> 💵 <]   |\n               [  👀  |  💵  |  😞  ]   |\n               [  💎  |  😀  |  👀  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  🍒  |  😞  |  💎  ]   O\n               [  😞  |  🍒  |  😀  ]   |\n"
            .STRINGZ "               [> 💵 <|> 👀 <|> 🍒 <]   |\n               [  😀  |  💎  |  💵  ]   |\n               [  👀  |  💵  |  😞  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  🍒  |  😀  |  👀  ]   O\n               [  😞  |  😞  |  💎  ]   |\n"
            .STRINGZ "               [> 💵 <|> 🍒 <|> 😀 <]   |\n               [  😀  |  👀  |  🍒  ]   |\n               [  👀  |  💎  |  💵  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  🍒  |  😀  |  😞  ]   O\n               [  😞  |  😞  |  👀  ]   |\n"
            .STRINGZ "               [> 💵 <|> 🍒 <|> 💎 <]   |\n               [  😀  |  👀  |  😀  ]   |\n               [  👀  |  💎  |  🍒  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  🍒  |  😀  |  💵  ]   O\n               [  😞  |  😞  |  😞  ]   |\n"
            .STRINGZ "               [> 💵 <|> 🍒 <|> 👀 <]   |\n               [  😀  |  👀  |  💎  ]   |\n               [  👀  |  💎  |  😀  ]___|\n               =======================                  \n\n\n\n"


sltM4Pt1Str .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  👀  |  🍒  |  😞  ]   O\n               [  😞  |  💎  |  💵  ]   |\n"
sltM4Pt2Str .STRINGZ "               [> 😀 <|> 👀 <|> 🍒 <]   |\n               [  💎  |  😀  |  💎  ]   |\n               [  🍒  |  😞  |  👀  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  💵  |  💵  |  😀  ]   O\n               [  👀  |  🍒  |  😞  ]   |\n"
            .STRINGZ "               [> 😞 <|> 💎 <|> 💵 <]   |\n               [  😀  |  👀  |  🍒  ]   |\n               [  💎  |  😀  |  💎  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  🍒  |  😞  |  👀  ]   O\n               [  💵  |  💵  |  😀  ]   |\n"
            .STRINGZ "               [> 👀 <|> 🍒 <|> 😞 <]   |\n               [  😞  |  💎  |  💵  ]   |\n               [  😀  |  👀  |  🍒  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  💎  |  😀  |  💎  ]   O\n               [  🍒  |  😞  |  👀  ]   |\n"
            .STRINGZ "               [> 💵 <|> 💵 <|> 😀 <]   |\n               [  👀  |  🍒  |  😞  ]   |\n               [  😞  |  💎  |  💵  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  😀  |  👀  |  🍒  ]   O\n               [  💎  |  😀  |  💎  ]   |\n"
            .STRINGZ "               [> 🍒 <|> 😞 <|> 👀 <]   |\n               [  💵  |  💵  |  😀  ]   |\n               [  👀  |  🍒  |  😞  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  😞  |  💎  |  💵  ]   O\n               [  😀  |  👀  |  🍒  ]   |\n"
            .STRINGZ "               [> 💎 <|> 😀 <|> 💎 <]   |\n               [  🍒  |  😞  |  👀  ]   |\n               [  💵  |  💵  |  😀  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  👀  |  🍒  |  😞  ]   O\n               [  😞  |  💎  |  💵  ]   |\n"
            .STRINGZ "               [> 😀 <|> 👀 <|> 🍒 <]   |\n               [  💎  |  😀  |  💎  ]   |\n               [  🍒  |  😞  |  👀  ]___|\n               =======================          v       \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  💵  |  💵  |  😀  ]   O\n               [  👀  |  🍒  |  😞  ]   |\n"
            .STRINGZ "               [> 😞 <|> 💎 <|> 💵 <]   |\n               [  😀  |  👀  |  🍒  ]   |\n               [  💎  |  😀  |  💎  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  🍒  |  😞  |  👀  ]   O\n               [  💵  |  💵  |  😀  ]   |\n"
            .STRINGZ "               [> 👀 <|> 🍒 <|> 😞 <]   |\n               [  😞  |  💎  |  💵  ]   |\n               [  😀  |  👀  |  🍒  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  🍒  |  😀  |  💎  ]   O\n               [  💵  |  😞  |  👀  ]   |\n"
            .STRINGZ "               [> 👀 <|> 💵 <|> 😀 <]   |\n               [  😞  |  🍒  |  😞  ]   |\n               [  😀  |  💎  |  💵  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  🍒  |  👀  |  🍒  ]   O\n               [  💵  |  😀  |  💎  ]   |\n"
            .STRINGZ "               [> 👀 <|> 😞 <|> 👀 <]   |\n               [  😞  |  💵  |  😀  ]   |\n               [  😀  |  🍒  |  😞  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  🍒  |  💎  |  💵  ]   O\n               [  💵  |  👀  |  🍒  ]   |\n"
            .STRINGZ "               [> 👀 <|> 😀 <|> 💎 <]   |\n               [  😞  |  😞  |  👀  ]   |\n               [  😀  |  💵  |  😀  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  🍒  |  🍒  |  😞  ]   O\n               [  💵  |  💎  |  💵  ]   |\n"
            .STRINGZ "               [> 👀 <|> 👀 <|> 🍒 <]   |\n               [  😞  |  😀  |  💎  ]   |\n               [  😀  |  😞  |  👀  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  🍒  |  🍒  |  😀  ]   O\n               [  💵  |  💎  |  😞  ]   |\n"
            .STRINGZ "               [> 👀 <|> 👀 <|> 💵 <]   |\n               [  😞  |  😀  |  🍒  ]   |\n               [  😀  |  😞  |  💎  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  🍒  |  🍒  |  👀  ]   O\n               [  💵  |  💎  |  😀  ]   |\n"
            .STRINGZ "               [> 👀 <|> 👀 <|> 😞 <]   |\n               [  😞  |  😀  |  💵  ]   |\n               [  😀  |  😞  |  🍒  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  🍒  |  🍒  |  💎  ]   O\n               [  💵  |  💎  |  👀  ]   |\n"
            .STRINGZ "               [> 👀 <|> 👀 <|> 😀 <]   |\n               [  😞  |  😀  |  😞  ]   |\n               [  😀  |  😞  |  💵  ]___|\n               =======================                  \n\n\n\n"

            .STRINGZ "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n                        THE SLOTS\n               =======================\n               [  🍒  |  🍒  |  🍒  ]   O\n               [  💵  |  💎  |  💎  ]   |\n"
            .STRINGZ "               [> 👀 <|> 👀 <|> 👀 <]   |\n               [  😞  |  😀  |  😀  ]   |\n               [  😀  |  😞  |  😞  ]___|\n               =======================                  \n\n\n\n"
  
  
creditspt1  .STRINGZ " \n_____________    ___     ___    ____________\n|             |  |   |   |   |  |            |\n|____     ____|  |   |   |   |  |   _________|\n     |   |       |   |   |   |  |  |\n     |   |       |   |___|   |  |  |_______\n     |   |       |    ___    |  |          |\n     |   |       |   |   |   |  |   _______|\n     |   |       |   |   |   |  |  |\n     |   |       |   |   |   |  |  |_________ \n     |   |       |   |   |   |  |            |\n     |___|       |___|   |___|  |____________|\n"
creditspt2  .STRINGZ " ____________    ___        __    _________\n|            |  |   \      |  |  |   ____  \ \n|   _________|  |    \     |  |  |   |   \  \ \n|  |            |     \    |  |  |   |    \  \ \n|  |_______     |  |\  \   |  |  |   |     \  \ \n|          |    |  | \  \  |  |  |   |      |  |\n|   _______|    |  |  \  \ |  |  |   |      |  |\n|  |            |  |   \  \|  |  |   |     /  /\n|  |_________   |  |    \     |  |   |    /  /\n|            |  |  |     \    |  |   |___/  /\n|____________|  |__|      \___|  |_________/\n"    

.END                          


