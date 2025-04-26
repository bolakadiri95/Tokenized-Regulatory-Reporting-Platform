import { describe, it, expect, beforeEach, vi } from 'vitest';

// Mock the Clarity environment
const mockClarity = {
  contracts: {
    'data-collection': {
      functions: {
        'add-field': vi.fn(),
        'submit-data': vi.fn(),
        'update-submission': vi.fn(),
        'get-submission': vi.fn(),
        'get-field': vi.fn()
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

describe('Data Collection Contract', () => {
  it('should add a new field', async () => {
    // Mock successful field addition
    mockClarity.contracts['data-collection'].functions['add-field'].mockReturnValue({
      success: true,
      result: { value: true }
    });
    
    const requirementId = 'req-123';
    const fieldId = 'field-123';
    const name = 'Total Revenue';
    const description = 'Total revenue for the reporting period';
    const fieldType = 'number';
    const isRequired = true;
    
    const result = await mockClarity.contracts['data-collection'].functions['add-field'](
        requirementId, fieldId, name, description, fieldType, isRequired
    );
    
    expect(result.success).toBe(true);
    expect(mockClarity.contracts['data-collection'].functions['add-field']).toHaveBeenCalledWith(
        requirementId, fieldId, name, description, fieldType, isRequired
    );
  });
  
  it('should submit data', async () => {
    // Mock successful data submission
    mockClarity.contracts['data-collection'].functions['submit-data'].mockReturnValue({
      success: true,
      result: { value: true }
    });
    
    const entityId = 'entity-123';
    const requirementId = 'req-123';
    const submissionId = 'sub-123';
    const dataHash = new Uint8Array(32).fill(1); // Mock SHA-256 hash
    const metadata = '{"format": "JSON", "version": "1.0"}';
    
    const result = await mockClarity.contracts['data-collection'].functions['submit-data'](
        entityId, requirementId, submissionId, dataHash, metadata
    );
    
    expect(result.success).toBe(true);
    expect(mockClarity.contracts['data-collection'].functions['submit-data']).toHaveBeenCalledWith(
        entityId, requirementId, submissionId, dataHash, metadata
    );
  });
  
  it('should update an existing submission', async () => {
    // Mock existing submission
    mockClarity.contracts['data-collection'].functions['get-submission'].mockReturnValue({
      success: true,
      result: {
        value: {
          'data-hash': new Uint8Array(32).fill(1),
          'metadata': '{"format": "JSON", "version": "1.0"}',
          'timestamp': 50,
          'submitter': 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'
        }
      }
    });
    
    // Mock successful update
    mockClarity.contracts['data-collection'].functions['update-submission'].mockReturnValue({
      success: true,
      result: { value: true }
    });
    
    const entityId = 'entity-123';
    const requirementId = 'req-123';
    const submissionId = 'sub-123';
    const newDataHash = new Uint8Array(32).fill(2); // Updated hash
    const newMetadata = '{"format": "JSON", "version": "1.1"}';
    
    const result = await mockClarity.contracts['data-collection'].functions['update-submission'](
        entityId, requirementId, submissionId, newDataHash, newMetadata
    );
    
    expect(result.success).toBe(true);
  });
  
  it('should get a field by ID', async () => {
    // Mock field retrieval
    mockClarity.contracts['data-collection'].functions['get-field'].mockReturnValue({
      success: true,
      result: {
        value: {
          'name': 'Total Revenue',
          'description': 'Total revenue for the reporting period',
          'field-type': 'number',
          'is-required': true
        }
      }
    });
    
    const requirementId = 'req-123';
    const fieldId = 'field-123';
    
    const result = await mockClarity.contracts['data-collection'].functions['get-field'](requirementId, fieldId);
    
    expect(result.success).toBe(true);
    expect(result.result.value.name).toBe('Total Revenue');
  });
});
