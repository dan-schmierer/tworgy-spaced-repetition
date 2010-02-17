module SuperMemo

  # This module can be used as a mixin to add the algorithms as used by 
  # SuperMemo 2 (typically referred to as SM2).  
  # 
  # See the README for more information.
  module SM2
    
    def SM2.included(obj)
      check_instance_variables(obj)
    end
    
    def SM2.extended(obj)
      check_instance_variables(obj)
    end
  
    def reset_spaced_repetition_data
      self.easiness_factor = 2.5  
      self.number_repetitions = 0  
      self.quality_of_last_recall = nil  
      self.next_repetition = Date.today  
    end

    def process_recall_result(quality_of_recall)
      if quality_of_recall < 3    
        self.number_repetitions = 0 
      else
        self.number_repetitions += 1
        self.easiness_factor = calculate_easiness_factor(easiness_factor, quality_of_recall)
      end
      
      case number_repetitions
      when 0
        self.repetition_interval = 0
      when 1
        self.repetition_interval = 1
      when 2
        self.repetition_interval = 6
      else
        self.repetition_interval = repetition_interval * easiness_factor
      end
      
      self.next_repetition = Date.today + repetition_interval
    end
    
    private 
    
    def SM2.check_instance_variables(obj)
      begin
        obj.send(:easiness_factor)
        obj.send(:number_repetitions)
        obj.send(:quality_of_last_recall)
        obj.send(:next_repetition)
      rescue NoMethodError => e
        DBC.assert(false, e.message)
      end
    end
    
    def calculate_easiness_factor(easiness_factor, quality_of_recall)
      q = quality_of_recall
      ef_old = easiness_factor

      result = ef_old - 0.8 + (0.28*q) - (0.02*q*q)
      result < 1.3 ? 1.3 : result
    end
    
  end
end
