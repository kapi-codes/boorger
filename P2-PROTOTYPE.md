# Player 2 (Plater) Prototype

Barebones prototype of the plating experience.

## Food Stack Blocks

- Randomly generated polyomino-like shapes within a 3x3 grid.
- Each block is made up of 2-9 connected unit squares (orthogonal connections only -- no diagonals).
- Blocks are clickable and draggable around the screen.
- Blocks should return to their original position if dropped in an invalid location.

## Customer Plate Grid

- A grid of unit squares forming the shape of a customer's plate.
- Starting plate: a briefcase shape, approximately 6 wide by 5 tall.
  - Rectangular 6x5 body with a 2x1 handle centered on top.
- Only one plate for now.

## Drag-and-Drop Placement

- The user clicks and drags a food stack block toward the plate grid.
- On release:
  - **Valid placement:** Every square of the block aligns with an empty square on the plate grid. The block snaps into place on the grid.
  - **Invalid placement:** The block overlaps a filled square, or any part of the block is outside the plate grid. The block returns to its original position.

## Out of Scope (for now)

- Player 1 (Catcher) gameplay.
- Networking / async communication between players.
- Art assets (use colored rectangles).
- Multiple plates or customers.
- Scoring, timers, or win/lose conditions.
