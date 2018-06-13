module VectorUtils

  def self.cross_product(a, b)
    return [ a[1]*b[2] - a[2]*b[1],
             a[2]*b[0] - a[0]*b[2],
             a[0]*b[1] - a[1]*b[0]]
  end

  def self.dot_product(a, b) return a.zip(b).map{|x, y| x*y }.reduce{|x, y| x+y} end

  def self.magnitude(a) return dot_product(a, a)**0.5 end

  def self.normalize(a) return a.map{|x| x/magnitude(a) } end
end
