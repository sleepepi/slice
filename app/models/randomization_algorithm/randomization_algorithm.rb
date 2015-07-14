require 'randomization_algorithm/algorithms/default'
require 'randomization_algorithm/algorithms/permuted_block'
require 'randomization_algorithm/algorithms/minimization'

module RandomizationAlgorithm

  DEFAULT_CLASS = RandomizationAlgorithm::Default
  ALGORITHM_CLASSES = {
    'permuted-block' => PermutedBlock,
    'minimization' => Minimization
  }

  def self.for(object)
    (ALGORITHM_CLASSES[object.algorithm] || DEFAULT_CLASS).new(object)
  end

end
