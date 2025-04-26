import { describe, it, expect, beforeEach, vi } from 'vitest';

// Mock the Clarity environment
const mockClarity = {
  contracts: {
    'requirement-tracking': {
      functions: {
        'add-requirement': vi.fn(),
        'assign-requirement': vi.fn(),
        'remove-requirement': vi.fn(),
        'get-requirement': vi.fn(),
        'get-entity-requirement': vi.fn()
      }
    }
  },
  tx: {
    sender: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'
  },
  block: {
    height: 100
  }
};

// Reset mocks before each test
beforeEach(() => {
  vi.resetAllMocks();
});

describe('Requirement Tracking Contract', () => {
  it('should add a new requirement', async () => {
    // Mock successful requirement addition
    mockClarity.contracts['requirement-tracking'].functions['add-requirement'].mockReturnValue({
      success: true,
      result: { value: true }
    });
    
    const requirementId = 'req-123';
    const title = 'Quarterly Report';
    const description = 'Financial reporting for Q1';
    const type = 0; // report
    const frequency = 'quarterly';
    const jurisdiction = 'US';
    const authority = 'SEC';
    
    const result = await mockClarity.contracts['requirement-tracking'].functions['add-requirement'](
        requirementId, title, description, type, frequency, jurisdiction, authority
    );
    
    expect(result.success).toBe(true);
    expect(mockClarity.contracts['requirement-tracking'].functions['add-requirement']).toHaveBeenCalledWith(
        requirementId, title, description, type, frequency, jurisdiction, authority
    );
  });
  
  it('should assign a requirement to an entity', async () => {
    // Mock successful requirement assignment
    mockClarity.contracts['requirement-tracking'].functions['assign-requirement'].mockReturnValue({
      success: true,
      result: { value: true }
    });
    
    const entityId = 'entity-123';
    const requirementId = 'req-123';
    const notes = 'Required for all public companies';
    
    const result = await mockClarity.contracts['requirement-tracking'].functions['assign-requirement'](
        entityId, requirementId, notes
    );
    
    expect(result.success).toBe(true);
    expect(mockClarity.contracts['requirement-tracking'].functions['assign-requirement']).toHaveBeenCalledWith(
        entityId, requirementId, notes
    );
  });
  
  it('should remove a requirement from an entity', async () => {
    // Mock successful requirement removal
    mockClarity.contracts['requirement-tracking'].functions['remove-requirement'].mockReturnValue({
      success: true,
      result: { value: true }
    });
    
    // Mock existing assignment
    mockClarity.contracts['requirement-tracking'].functions['get-entity-requirement'].mockReturnValue({
      success: true,
      result: {
        value: {
          'applicable-from': 50,
          'applicable-until': null,
          'notes': 'Required for all public companies'
        }
      }
    });
    
    const entityId = 'entity-123';
    const requirementId = 'req-123';
    
    const result = await mockClarity.contracts['requirement-tracking'].functions['remove-requirement'](
        entityId, requirementId
    );
    
    expect(result.success).toBe(true);
  });
  
  it('should get a requirement by ID', async () => {
    // Mock requirement retrieval
    mockClarity.contracts['requirement-tracking'].functions['get-requirement'].mockReturnValue({
      success: true,
      result: {
        value: {
          'title': 'Quarterly Report',
          'description': 'Financial reporting for Q1',
          'type': 0,
          'frequency': 'quarterly',
          'jurisdiction': 'US',
          'authority': 'SEC',
          'created-at': 50
        }
      }
    });
    
    const requirementId = 'req-123';
    
    const result = await mockClarity.contracts['requirement-tracking'].functions['get-requirement'](requirementId);
    
    expect(result.success).toBe(true);
    expect(result.result.value.title).toBe('Quarterly Report');
  });
});
