module ATLTileCalTBGeometry
    export numberOfCells, cellLUT, getGellIndex, Cell, TCModule, TCRow

    using StaticArrays

    @enum TCModule LONG_LOWER LONG_UPPER EXTENDED EXTENDED_C10 EXTENDED_D4
    @enum TCRow A B BC C D

    for s in instances(TCModule)
        @eval export $(Symbol(s))
    end
    for s in instances(TCRow)
        @eval export $(Symbol(s))
    end

    struct Cell
        modul::TCModule
        row::TCRow
        nCell::Int
        firstRow::Int
        lastRow::Int
        nTilesRow::SizedVector{6,Int}
        Cell(m, r, n, f, l, tiles...) = new(m, r, n, f, l, tiles)
    end

    #---Total numbers of cells---------------------------------------------------------------------
    const numberOfCells = 104
    #---Cell Look Up Table-------------------------------------------------------------------------
    const cellLUT = SVector{numberOfCells, Cell}(  
        Cell(LONG_LOWER, A, -10,  1,  3, 16, 16, 16,  0,  0,  0), #   0
        Cell(LONG_LOWER, A,  -9,  1,  3, 18, 19, 18,  0,  0,  0), #   1
        Cell(LONG_LOWER, A,  -8,  1,  3, 18, 17, 18,  0,  0,  0), #   2
        Cell(LONG_LOWER, A,  -7,  1,  3, 16, 16, 16,  0,  0,  0), #   3
        Cell(LONG_LOWER, A,  -6,  1,  3, 15, 16, 15,  0,  0,  0), #   4
        Cell(LONG_LOWER, A,  -5,  1,  3, 15, 15, 15,  0,  0,  0), #   5
        Cell(LONG_LOWER, A,  -4,  1,  3, 14, 14, 14,  0,  0,  0), #   6
        Cell(LONG_LOWER, A,  -3,  1,  3, 14, 14, 14,  0,  0,  0), #   7
        Cell(LONG_LOWER, A,  -2,  1,  3, 14, 13, 14,  0,  0,  0), #   8
        Cell(LONG_LOWER, A,  -1,  1,  3, 13, 14, 13,  0,  0,  0), #   9
        Cell(LONG_LOWER, A,   1,  1,  3, 14, 13, 14,  0,  0,  0), #  10
        Cell(LONG_LOWER, A,   2,  1,  3, 13, 14, 13,  0,  0,  0), #  11
        Cell(LONG_LOWER, A,   3,  1,  3, 14, 14, 14,  0,  0,  0), #  12
        Cell(LONG_LOWER, A,   4,  1,  3, 14, 14, 14,  0,  0,  0), #  13
        Cell(LONG_LOWER, A,   5,  1,  3, 15, 15, 15,  0,  0,  0), #  14
        Cell(LONG_LOWER, A,   6,  1,  3, 16, 15, 16,  0,  0,  0), #  15
        Cell(LONG_LOWER, A,   7,  1,  3, 16, 16, 16,  0,  0,  0), #  16
        Cell(LONG_LOWER, A,   8,  1,  3, 17, 18, 17,  0,  0,  0), #  17
        Cell(LONG_LOWER, A,   9,  1,  3, 19, 18, 19,  0,  0,  0), #  18
        Cell(LONG_LOWER, A,  10,  1,  3, 16, 16, 16,  0,  0,  0), #  19
        Cell(LONG_LOWER, BC, -9,  4,  9, 18, 17, 18,  0,  0,  0), #  20
        Cell(LONG_LOWER, BC, -8,  4,  9, 20, 20, 20, 20, 20, 20), #  21
        Cell(LONG_LOWER, BC, -7,  4,  9, 18, 19, 18, 21, 22, 21), #  22
        Cell(LONG_LOWER, BC, -6,  4,  9, 18, 18, 18, 21, 20, 21), #  23
        Cell(LONG_LOWER, BC, -5,  4,  9, 17, 16, 17, 19, 19, 19), #  24
        Cell(LONG_LOWER, BC, -4,  4,  9, 16, 17, 16, 19, 19, 19), #  25
        Cell(LONG_LOWER, BC, -3,  4,  9, 16, 15, 16, 18, 18, 18), #  26
        Cell(LONG_LOWER, BC, -2,  4,  9, 15, 16, 15, 18, 18, 18), #  27
        Cell(LONG_LOWER, BC, -1,  4,  9, 16, 15, 16, 17, 18, 17), #  28
        Cell(LONG_LOWER, BC,  1,  4,  9, 15, 16, 15, 18, 17, 18), #  29
        Cell(LONG_LOWER, BC,  2,  4,  9, 16, 15, 16, 18, 18, 18), #  30
        Cell(LONG_LOWER, BC,  3,  4,  9, 15, 16, 15, 18, 18, 18), #  31
        Cell(LONG_LOWER, BC,  4,  4,  9, 17, 16, 17, 19, 19, 19), #  32
        Cell(LONG_LOWER, BC,  5,  4,  9, 16, 17, 16, 19, 19, 19), #  33
        Cell(LONG_LOWER, BC,  6,  4,  9, 18, 18, 18, 20, 21, 20), #  34
        Cell(LONG_LOWER, BC,  7,  4,  9, 19, 18, 19, 22, 21, 22), #  35
        Cell(LONG_LOWER, BC,  8,  4,  9, 20, 20, 20, 20, 20, 20), #  36
        Cell(LONG_LOWER, BC,  9,  4,  9, 17, 18, 17,  0,  0,  0), #  37
        Cell(LONG_LOWER, D,  -3, 10, 11, 50, 50,  0,  0,  0,  0), #  38
        Cell(LONG_LOWER, D,  -2, 10, 11, 43, 43,  0,  0,  0,  0), #  39
        Cell(LONG_LOWER, D,  -1, 10, 11, 41, 40,  0,  0,  0,  0), #  40
        Cell(LONG_LOWER, D,   0, 10, 11, 40, 40,  0,  0,  0,  0), #  41
        Cell(LONG_LOWER, D,   1, 10, 11, 40, 41,  0,  0,  0,  0), #  42
        Cell(LONG_LOWER, D,   2, 10, 11, 43, 43,  0,  0,  0,  0), #  43
        Cell(LONG_LOWER, D,   3, 10, 11, 50, 50,  0,  0,  0,  0), #  44
        # Upper long module
        Cell(LONG_UPPER, A, -10,  1,  3, 16, 16, 16,  0,  0,  0), #  45
        Cell(LONG_UPPER, A,  -9,  1,  3, 18, 19, 18,  0,  0,  0), #  46
        Cell(LONG_UPPER, A,  -8,  1,  3, 18, 17, 18,  0,  0,  0), #  47
        Cell(LONG_UPPER, A,  -7,  1,  3, 16, 16, 16,  0,  0,  0), #  48
        Cell(LONG_UPPER, A,  -6,  1,  3, 15, 16, 15,  0,  0,  0), #  49
        Cell(LONG_UPPER, A,  -5,  1,  3, 15, 15, 15,  0,  0,  0), #  50
        Cell(LONG_UPPER, A,  -4,  1,  3, 14, 14, 14,  0,  0,  0), #  51
        Cell(LONG_UPPER, A,  -3,  1,  3, 14, 14, 14,  0,  0,  0), #  52
        Cell(LONG_UPPER, A,  -2,  1,  3, 14, 13, 14,  0,  0,  0), #  53
        Cell(LONG_UPPER, A,  -1,  1,  3, 13, 14, 13,  0,  0,  0), #  54
        Cell(LONG_UPPER, A,   1,  1,  3, 14, 13, 14,  0,  0,  0), #  55
        Cell(LONG_UPPER, A,   2,  1,  3, 13, 14, 13,  0,  0,  0), #  56
        Cell(LONG_UPPER, A,   3,  1,  3, 14, 14, 14,  0,  0,  0), #  57
        Cell(LONG_UPPER, A,   4,  1,  3, 14, 14, 14,  0,  0,  0), #  58
        Cell(LONG_UPPER, A,   5,  1,  3, 15, 15, 15,  0,  0,  0), #  59
        Cell(LONG_UPPER, A,   6,  1,  3, 16, 15, 16,  0,  0,  0), #  60
        Cell(LONG_UPPER, A,   7,  1,  3, 16, 16, 16,  0,  0,  0), #  61
        Cell(LONG_UPPER, A,   8,  1,  3, 17, 18, 17,  0,  0,  0), #  62
        Cell(LONG_UPPER, A,   9,  1,  3, 19, 18, 19,  0,  0,  0), #  63
        Cell(LONG_UPPER, A,  10,  1,  3, 16, 16, 16,  0,  0,  0), #  64
        Cell(LONG_UPPER, BC, -9,  4,  9, 18, 17, 18,  0,  0,  0), #  65
        Cell(LONG_UPPER, BC, -8,  4,  9, 20, 20, 20, 20, 20, 20), #  66
        Cell(LONG_UPPER, BC, -7,  4,  9, 18, 19, 18, 21, 22, 21), #  67
        Cell(LONG_UPPER, BC, -6,  4,  9, 18, 18, 18, 21, 20, 21), #  68
        Cell(LONG_UPPER, BC, -5,  4,  9, 17, 16, 17, 19, 19, 19), #  69
        Cell(LONG_UPPER, BC, -4,  4,  9, 16, 17, 16, 19, 19, 19), #  70
        Cell(LONG_UPPER, BC, -3,  4,  9, 16, 15, 16, 18, 18, 18), #  71
        Cell(LONG_UPPER, BC, -2,  4,  9, 15, 16, 15, 18, 18, 18), #  72
        Cell(LONG_UPPER, BC, -1,  4,  9, 16, 15, 16, 17, 18, 17), #  73
        Cell(LONG_UPPER, BC,  1,  4,  9, 15, 16, 15, 18, 17, 18), #  74
        Cell(LONG_UPPER, BC,  2,  4,  9, 16, 15, 16, 18, 18, 18), #  75
        Cell(LONG_UPPER, BC,  3,  4,  9, 15, 16, 15, 18, 18, 18), #  76
        Cell(LONG_UPPER, BC,  4,  4,  9, 17, 16, 17, 19, 19, 19), #  77
        Cell(LONG_UPPER, BC,  5,  4,  9, 16, 17, 16, 19, 19, 19), #  78
        Cell(LONG_UPPER, BC,  6,  4,  9, 18, 18, 18, 20, 21, 20), #  79
        Cell(LONG_UPPER, BC,  7,  4,  9, 19, 18, 19, 22, 21, 22), #  80
        Cell(LONG_UPPER, BC,  8,  4,  9, 20, 20, 20, 20, 20, 20), #  81
        Cell(LONG_UPPER, BC,  9,  4,  9, 17, 18, 17,  0,  0,  0), #  82
        Cell(LONG_UPPER, D,  -3, 10, 11, 50, 50,  0,  0,  0,  0), #  83
        Cell(LONG_UPPER, D,  -2, 10, 11, 43, 43,  0,  0,  0,  0), #  84
        Cell(LONG_UPPER, D,  -1, 10, 11, 41, 40,  0,  0,  0,  0), #  85
        Cell(LONG_UPPER, D,   0, 10, 11, 40, 40,  0,  0,  0,  0), #  86
        Cell(LONG_UPPER, D,   1, 10, 11, 40, 41,  0,  0,  0,  0), #  87
        Cell(LONG_UPPER, D,   2, 10, 11, 43, 43,  0,  0,  0,  0), #  88
        Cell(LONG_UPPER, D,   3, 10, 11, 50, 50,  0,  0,  0,  0), #  89
        # Extended module
        Cell(EXTENDED,   A,  12,  1,  3,  9,  9,  9,  0,  0,  0), #  90
        Cell(EXTENDED,   A,  13,  1,  3, 25, 25, 25,  0,  0,  0), #  91
        Cell(EXTENDED,   A,  14,  1,  3, 28, 28, 28,  0,  0,  0), #  92
        Cell(EXTENDED,   A,  15,  1,  3, 30, 30, 30,  0,  0,  0), #  93
        Cell(EXTENDED,   A,  16,  1,  3, 48, 48, 48,  0,  0,  0), #  94
        Cell(EXTENDED,   B,  11,  4,  7, 16, 16, 16, 16,  0,  0), #  95
        Cell(EXTENDED,   B,  12,  4,  7, 27, 27, 27, 27,  0,  0), #  96
        Cell(EXTENDED,   B,  13,  4,  7, 30, 30, 30, 30,  0,  0), #  97
        Cell(EXTENDED,   B,  14,  4,  7, 32, 32, 32, 32,  0,  0), #  98
        Cell(EXTENDED,   B,  15,  4,  7, 35, 35, 35, 35,  0,  0), #  99
        Cell(EXTENDED,   D,   5,  8, 11, 65, 65, 65, 65,  0,  0), # 100
        Cell(EXTENDED,   D,   6,  8, 11, 75, 75, 75, 75,  0,  0), # 101
        Cell(EXTENDED_C10, C,  10,  1,  3,  6,  5,  6,  0,  0,  0), # 102
        Cell(EXTENDED_D4,  D,   4,  4,  5, 17, 17,  0,  0,  0,  0), # 103
    )

    const long_module_no_cells = 45
    const long_module_row_A_lastrow = 3
    const long_module_row_A_no_cells = 20
    const long_module_row_BC_lastrow = 9
    const long_module_row_BC_no_cells = 18
    const extended_module_row_A_lastrow = 3
    const extended_module_A_no_cells = 5
    const extended_module_row_B_lastrow = 7
    const extended_module_B_no_cells = 5

    #----Finds the cell index given a module, the row index and the cell index
    function getGellIndex(modul::TCModule, rowIdx, tileIdx)

        index = 1

        #  Fast forward module
        if modul == LONG_UPPER
            index += long_module_no_cells
        elseif modul == EXTENDED
            index += 2 * long_module_no_cells
        elseif modul == EXTENDED_C10
            return numberOfCells - 1
        elseif modul == EXTENDED_D4
            return numberOfCells
        end

        # Row indices start with 1 in ATLAS convention
        rowIdx += 1

        # Fast forward row
        if modul != EXTENDED
            if rowIdx > long_module_row_A_lastrow
                index += long_module_row_A_no_cells
            end
            if rowIdx > long_module_row_BC_lastrow
                index += long_module_row_BC_no_cells
            end
        else 
            # Note: ignore ITC module as LONG_LOWERhandled before
            if rowIdx > extended_module_row_A_lastrow
                index += extended_module_A_no_cells
            end
            if rowIdx > extended_module_row_B_lastrow
                index += extended_module_B_no_cells
            end
        end

        # Get index for nTilesRow, stays constant in a row
        n_tiles_row_index = rowIdx - cellLUT[index].firstRow

        # G4cout << "row " << rowIdx << " fast-forwarded index " << index << " " << GetCell(index).to_string() << G4endl

        # Count trough cells and comapre to periods
        index -= 1
        counter = 0
        next_cell_count = 0
        while true
            index += 1
            counter += next_cell_count
            next_cell_count = cellLUT[index].nTilesRow[n_tiles_row_index + 1]
            # G4cout << "index " << index << " counter " << counter << " next_cell_count " << next_cell_count << " sum " << counter + next_cell_count << G4endl
            tileIdx < counter + next_cell_count && break 
        end

        # Sanity check
        if index > numberOfCells
            throw("Cell with index $index does not exist, row index $rowIdx and tile index $tileIdx are probably out of range.")
        end
        return index
    end
end
