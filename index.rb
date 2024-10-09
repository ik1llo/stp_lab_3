def get_raisin_positions (cake)
  raisin_positions = []

  cake.each_with_index do |r, r_idx|
    r.chars.each_with_index do |c, c_idx|
      raisin_positions << [r_idx, c_idx] if c == "o"
    end
  end

  raisin_positions
end

def generate_vert_slices (cake, raisin_positions)
  c_count = cake[0].length
  pieces_by_c = Array.new(c_count) { [] }

  (0...cake.length).each do |r|
    (0...c_count).each do |c|
      pieces_by_c[c] << cake[r][c]
    end
  end

  vert_pcs = []
  start_c = 0

  raisin_positions.each_with_index do |(_, y), index|
    end_c = index == raisin_positions.length - 1 ? c_count - 1 : y
    vert_pcs << pieces_by_c[start_c..end_c].map(&:join)
    start_c = end_c + 1
  end

  vert_pcs
end

def generate_hor_slices (cake, raisin_positions)
  hor_pieces = []
  start_r = 0

  raisin_positions.each_with_index do |(x, _), index|
    end_r = index == raisin_positions.length - 1 ? cake.length - 1 : x
    hor_pieces << cake[start_r..end_r]
    start_r = end_r + 1
  end

  hor_pieces
end

def generate_diag_slices (cake)
  diag_pieces = []

  r_count = cake.length
  c_count = cake[0].length

  (0...r_count).each do |i|
    diag_piece = []

    (0...[r_count, c_count].min).each do |j| 
      diag_piece << cake[i + j][j] if (i + j) < r_count && j < c_count
    end

    diag_pieces << diag_piece.join unless diag_piece.empty?
  end

  diag_pieces
end

def generate_mixed_slices (cake, raisin_positions)
  vert = generate_vert_slices(cake, raisin_positions)
  hor = generate_hor_slices(cake, raisin_positions)
  diag = generate_diag_slices(cake)

  [hor, vert, diag]
end

def is_valid_slice? (cake, slices)
  first_piece_size = slices[0].is_a?(Array) ? slices[0].length : slices[0].size

  slices.each do |slice|
    raisin_count =  if slice.is_a?(Array)
                      slice.map { |r| r.count("o") }.sum
                    else
                      slice.count("o")
                    end

    return false if raisin_count != 1

    current_piece_size = slice.is_a?(Array) ? slice.length : slice.size
    return false if current_piece_size != first_piece_size 
  end
  true
end

def slice_cake (cake)
  raisin_positions = get_raisin_positions(cake)

  return "[info]: impossible to cut the cake..." if raisin_positions.empty? || raisin_positions.size < 2

  vert_slices = generate_vert_slices(cake, raisin_positions)
  hor_slices = generate_hor_slices(cake, raisin_positions)
  diag_slices = generate_diag_slices(cake)
  mixed_slices = generate_mixed_slices(cake, raisin_positions)

  all_slices = [hor_slices, vert_slices, diag_slices] + mixed_slices
  valid_slices = all_slices.select { |slices| is_valid_slice?(cake, slices) }

  return "[info]: there are no possible cuts..." if valid_slices.empty?

  valid_slices
end

def get_best_slice_solution (solutions)
  best_solution = nil
  m_width = 0

  solutions.each do |solution|
    first_piece = solution[0]
    width = first_piece.is_a?(Array) ? first_piece[0].length : first_piece.length
    if width > m_width
      m_width = width
      best_solution = solution
    end
  end

  best_solution
end

cake = [
  "........",
  ".....o..",
  "...o....",
  "........" 
]

slices = slice_cake(cake)
if slices.is_a?(String)
  puts slices
else
  best_solution = get_best_slice_solution(slices)

  best_solution.each_with_index do |slice, index|
    puts "#{index + 1}."
    slice.each { |line| puts "\"#{line}\"" }
    puts "\n"
  end
end