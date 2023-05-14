ctx.createRectangularRegion("region", 1, 1, 1, 40)

for cell, cellinfo in ctx.cells:
    print("Floorplan", cell)
    if "TuringMachine" in str(cell):
        print("Constrain", cell)
        ctx.constrainCellToRegion(cell, "region")
